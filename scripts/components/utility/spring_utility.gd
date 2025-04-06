#Paste article here later

class_name SpringUtility

class SpringParams: #maybe resourcify it in another class to allow easier exporting
	var pos : float
	var vel : float

	func _init(springPosition : float = 0.0, springVelocity : float = 0.0):
		pos = springPosition
		vel = springVelocity

class SpringMotionParams:
	var posPosCoef : float
	var posVelCoef : float
	var velPosCoef : float
	var velVelCoef : float

static func CalcSpringMotionParams(delta : float, angularFreq : float, dampingRatio : float)->SpringMotionParams:
	#Ryan Jucketts implementation suggests passing a reference to SMP instead of creating a new one to cache it
	var springMotionParams : SpringMotionParams = SpringMotionParams.new()

	const epsilon : float = 0.0001

	if (dampingRatio < 0.0): dampingRatio = 0.0
	if (angularFreq < 0.0): angularFreq = 0.0

	if (angularFreq < epsilon):
		springMotionParams.posPosCoef = 1.0
		springMotionParams.posVelCoef = 0.0
		springMotionParams.velPosCoef = 0.0
		springMotionParams.velPosCoef = 1.0
		return springMotionParams

	if (dampingRatio > 1.0 + epsilon):
		#over damped
		var za : float = -angularFreq * dampingRatio
		var zb : float = angularFreq * sqrt(dampingRatio*dampingRatio - 1.0)
		var z1 : float = za - zb
		var z2 : float = za + zb

		var e1 : float = exp(z1 * delta)
		var e2 : float = exp(z2 * delta)

		var invTwoZb : float = 1.0 / (2.0 * zb)

		var e1OverTwoZb : float = e1*invTwoZb
		var e2OverTwoZb : float = e2*invTwoZb

		var z1e1OverTwoZb : float = z1*e1OverTwoZb
		var z2e2OverTwoZb : float = z2*e2OverTwoZb

		springMotionParams.posPosCoef = e1OverTwoZb*z2 - z2e2OverTwoZb + e2
		springMotionParams.posVelCoef = -e1OverTwoZb + e2OverTwoZb

		springMotionParams.velPosCoef = (z1e1OverTwoZb - z2e2OverTwoZb + e2) * z2
		springMotionParams.velVelCoef = -z1e1OverTwoZb + z2e2OverTwoZb
	elif (dampingRatio < 1.0 - epsilon):
		#under damped
		var omegaZeta : float = angularFreq * dampingRatio
		var alpha : float = angularFreq * sqrt(1.0 - dampingRatio*dampingRatio)

		var expTerm : float = exp(-omegaZeta * delta)
		var cosTerm : float = cos(alpha * delta)
		var sinTerm : float = sin(alpha * delta)

		var invAlpha : float = 1.0 / alpha

		var expSin : float = expTerm * sinTerm
		var expCos : float = expTerm * cosTerm
		var expOmegaZetaSinOverAlpha : float = expTerm * omegaZeta * sinTerm * invAlpha

		springMotionParams.posPosCoef = expCos + expOmegaZetaSinOverAlpha
		springMotionParams.posVelCoef = expSin*invAlpha

		springMotionParams.velPosCoef = -expSin*alpha - omegaZeta*expOmegaZetaSinOverAlpha
		springMotionParams.velVelCoef = expCos - expOmegaZetaSinOverAlpha
	else:
		#critically damped
		var expTerm : float = exp(-angularFreq * delta)
		var timeExp : float = delta *expTerm
		var timeExpFreq : float = timeExp * angularFreq

		springMotionParams.posPosCoef = timeExpFreq + expTerm
		springMotionParams.posVelCoef = timeExp

		springMotionParams.velPosCoef = -angularFreq * timeExpFreq
		springMotionParams.velVelCoef = -timeExpFreq + expTerm

	return springMotionParams

static func UpdateSpringMotion(springParams : SpringParams, equilibriumPos : float, springMotionParams : SpringMotionParams):
	var oldPos : float = springParams.pos - equilibriumPos
	var oldVel : float = springParams.vel

	springParams.pos = oldPos*springMotionParams.posPosCoef + oldVel*springMotionParams.posVelCoef + equilibriumPos
	springParams.vel = oldPos*springMotionParams.velPosCoef + oldVel*springMotionParams.velVelCoef

	#How to use (I think):
		#Init a spring (SpringParams)
		#Each frame get relevant SpringMotionParams
		#Pass SpringParams in to this function to update it according to motion params

#Or just call this function ig..
static func UpdateSpring(springParams : SpringParams, equilibriumPos : float, delta : float, angularFreq : float = 10.0, dampingRatio : float = 1.0):
	UpdateSpringMotion(springParams, equilibriumPos, CalcSpringMotionParams(delta, angularFreq, dampingRatio))