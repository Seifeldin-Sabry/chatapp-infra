const User = require('./../models/userModel')
const catchAsync = require('./../utils/catchAsync')
const AppError = require('./../utils/appError');
const sendEmail = require('./../utils/emails');
const jwt = require('jsonwebtoken')
const { promisify } = require('util')
const bcrypt = require('bcrypt');
const crypto = require("crypto");

const signToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRES_IN
    })
}


exports.signUp = catchAsync(async (req, res, next) => {
  const { name, email, password, passwordConfirm} = req.body
  const newUser = await User.create({
    name,
    email,
    password,
    passwordConfirm
  })

  const token = signToken(newUser._id)

  res.status(201).json({
    status: "success",
    token,
    data: {
      user: newUser
    }
  })
})

exports.login = async (req, res, next) => {
  const { email, password } = req.body

  //steps to login
  // 1) check if email and password exist
  if (!email || !password){
    return next(new AppError('email or password not provided', 400))
  }
  // 2) check if user exists
  const user = await User.findOne({
    email
  }).select('+password')

  if ( !user || !(await user.verifyPassword(password))){
    return next(new AppError('Incorrect email or password', 401))
  }

  // 3) send the jwt back to client
  const token = signToken(user._id)
  res.status(200).json({
    status: "success",
    token
  })
}


exports.protect = catchAsync(async (req, res, next) => {
  let token;

  // 1) Getting token and checking if it's there
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1]
  }

  if (!token) return next(new AppError('You are not logged in, please log in/sign up to get access', 401))
  // 2) Verification token
  const decoded = await promisify(jwt.verify)(token, process.env.JWT_SECRET)
  // 3) user exists
  const currentUser = await User.findById(decoded.id)
  if (!currentUser) return next(new AppError('The user belonging to this token does not exist', 401))


  // 4) if user changed password
  const passwordChanged = currentUser.changedPasswordAfterLogin(decoded.iat)
  if (passwordChanged) return next(new AppError('User recently changed password! Please log in again'))

  //GRANT ACCESS TO PROTECTED ROUTE
  req.user = currentUser
  next();
})


exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) return next(new AppError('permission denied', 403))
    else next();
  }
}

exports.forgotPassword = catchAsync(async (req, res, next) => {
  //1 get user email
  const user = await User.findOne({email: req.body.email})
  if (!user) return next(new AppError('no user with that email found', 404))

  //store reset token
  const resetToken = user.createPasswordResetToken()
  await user.save({validateBeforeSave: false})

  const resetURL = `${req.protocol}://${req.get('host')}/api/v1/user/resetPassword/${resetToken}`

  const message = `Forgot your password? Submit a PATCH request with your new password, and passwordConfirm to ${resetURL}`

  try {
    await sendEmail({
      email: user.email,
      subject: 'Your password reset token (expires in 10 minutes)',
      message
    })
  }catch (e){
    user.passwordResetToken = undefined
    user.passwordResetExpired = undefined
    await user.save({validateBeforeSave: false})

    return next(new AppError('There was an error sending the email, try again later', 500))
  }


  res.status(200).json({
    status: 'success',
    message: "token sent to your email"
  })
})

exports.resetPassword = catchAsync( async (req, res, next) => {
  const PASSWORD_PARAMS_LENGTH = 2;
  if (Object.keys(req.body).length !== PASSWORD_PARAMS_LENGTH)
    return next(new AppError('Data sent has to be an object with two pieces of data: password and passwordConfirm', 401))

  const {password, passwordConfirm} = req.body


  const tokenEncrypted = crypto.createHash('sha256').update(req.params.token).digest('hex')

  const user =
    await User
        .findOne(
          {
            passwordResetToken: tokenEncrypted,
            passwordResetExpires: {
              $gt: Date.now()
            }
          })

  if (!user) return next(new AppError('Invalid Token or Expired', 400))

  user.password = password
  user.passwordConfirm = passwordConfirm
  user.passwordResetToken = undefined
  user.passwordResetExpires = undefined
  await user.save();

  const token = signToken(user._id)
  res.status(200).json({
    status: "success",
    token
  })
})

exports.updatePassword = catchAsync( async (req, res, next) => {
  //Verify all data is provided
  const requiredParams = ['currentPassword', 'newPassword']
  for (const param of requiredParams) {
    if(!Object.keys(req.body).includes(param)) return next(new AppError('Did not provide required data to reset password. Please provide your email, currentPassword, and newPassword', 406))
  }

  const {currentPassword, newPassword} = req.body;

  
  // Get user from collection
  const user = await User.findById(req.user.id)

  if (!user || !(await user.verifyPassword(currentPassword, user.password))) return next(new AppError('Incorrect email or password', 404))

  // If the password is correct, update password
  user.password = newPassword
  user.passwordConfirm = newPassword
  await user.save()

  // Log user in
  const token = signToken(user._id)
  res.status(200).json({
    status: "success",
    token
  })
})
