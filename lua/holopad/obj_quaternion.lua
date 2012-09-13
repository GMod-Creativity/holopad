/******************************************************************************\
  Quaternion support
  Converted from Wiremod's E2 Quaternion library for general lua use by Bubbus
  http://wiki.wiremod.com/?title=Expression2#Quaternion
\******************************************************************************/

// TODO: implement more!

-- faster access to some math library functions
local abs   = math.abs
local Round = math.Round
local sqrt  = math.sqrt
local exp   = math.exp
local log   = math.log
local sin   = math.sin
local cos   = math.cos
local sinh  = math.sinh
local cosh  = math.cosh
local acos  = math.acos

local deg2rad = math.pi/180
local rad2deg = 180/math.pi



local class_mt
Quat = {}
class_mt = {__index = Quat}
Quat.__metatable = class_mt
class_mt.__type = "quaternion"
setmetatable(Quat, class_mt)
Quaternion = Quat



/****************************** Helper functions ******************************/

local function quicknew(r, i, j, k)
	local new = {r, i, j, k}
	setmetatable( new, class_mt )
	return new
end

local function qmul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
	return quicknew(
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	)
end

local function qexp(q)
	local m = sqrt(q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
	local u
	if m ~= 0 then
		u = { q[2]*sin(m)/m, q[3]*sin(m)/m, q[4]*sin(m)/m }
	else
		u = { 0, 0, 0 }
	end
	local r = exp(q[1])
	return quicknew( r*cos(m), r*u[1], r*u[2], r*u[3] )
end

local function qlog(q)
	local l = sqrt(q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
	if l == 0 then return { -1e+100, 0, 0, 0 } end
	local u = { q[1]/l, q[2]/l, q[3]/l, q[4]/l }
	local a = acos(u[1])
	local m = sqrt(u[2]*u[2] + u[3]*u[3] + u[4]*u[4])
	if abs(m) > delta then
		return quicknew( log(l), a*u[2]/m, a*u[3]/m, a*u[4]/m )
	else
		return quicknew( log(l), 0, 0, 0 )  --when m is 0, u[2], u[3] and u[4] are 0 too
	end
end

/******************************************************************************/




local argTypesToQuat = {}
argTypesToQuat["number"] = function(args)
	return {args[1], 0, 0, 0}		
end

argTypesToQuat["Vector"] = function(args)
	vec = args[1]
	return {0, vec.x, vec.y, vec.z}
end

argTypesToQuat["Angle"] = function(args)
	local ang = args[1]
	local p, y, r = ang.p, ang.y, ang.r
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end

argTypesToQuat["numberVector"] = function(args)
	local vec = args[2]
	local quat = {args[1], vec.x, vec.y, vec.z}
	setmetatable( quat, class_mt )
	return quat
end

argTypesToQuat["VectorVector"] = function(args)
	local forward = args[1]
	local up = args[2]
	local x = Vector(forward.x, forward.y, forward.z)
	local z = Vector(up.x, up.y, up.z)
	local y = z:Cross(x):GetNormalized() --up x forward = left

	local ang = x:Angle()
	if ang.p > 180 then ang.p = ang.p - 360 end
	if ang.y > 180 then ang.y = ang.y - 360 end

	local yyaw = Vector(0,1,0)
	yyaw:Rotate(Angle(0,ang.y,0))

	local roll = acos(math.Clamp(y:Dot(yyaw), -1, 1))*rad2deg

	local dot = y.z
	if dot < 0 then roll = -roll end

	local p, y, r = ang.p, ang.y, roll
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end

argTypesToQuat["Entity"] = function(args)
	local ent = args[1]
	
	if !ent:IsValid() then
		return { 0, 0, 0, 0 }
	end
	
	local ang = ent:GetAngles()
	local p, y, r = ang.p, ang.y, ang.r
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end
	



function Quat:New(...)
	local args = {...}
	
	local numargs = #args
	local argtypes
	
	if numargs == 0 then 
		local new = {0,0,0,0}
		setmetatable( new, class_mt )
		return new
	end
	
	// please forgive me :(
	if numargs == 1 then argtypes = type(args[1]) end
	if numargs == 4 and (type(args[1]) == "number" and type(args[2]) == "number" and type(args[3]) == "number" and type(args[4]) == "number") then
		return quicknew(args[1], args[2], args[3], args[4])
	end
	if numargs > 1  then argtypes = type(args[1]) .. type(args[2]) end
	
	local argstonew = argTypesToQuat[argtypes]
	
	if !argstonew then 
		argstonew = argTypesToQuat[type(args[1])]
		if !argstonew then
			local new = {0,0,0,0}
			setmetatable( new, class_mt )
			return new
		end
	end
	
	local new = argstonew(args)
	setmetatable( new, class_mt )
	
	return new
end
class_mt.__call = Quat.New




local function format(value)
	local r,i,j,k,dbginfo

	r = ""
	i = ""
	j = ""
	k = ""

	if abs(value[1]) > 0.0005 then
		r = Round(value[1]*1000)/1000
	end
	dbginfo = r
	if abs(value[2]) > 0.0005 then
		i = tostring(Round(value[2]*1000)/1000)
		if string.sub(i,1,1)!="-" and dbginfo != "" then i = "+"..i end
		i = i .. "i"
	end
	dbginfo = dbginfo .. i
	if abs(value[3]) > 0.0005 then
		j = tostring(Round(value[3]*1000)/1000)
		if string.sub(j,1,1)!="-" and dbginfo != "" then j = "+"..j end
		j = j .. "j"
	end
	dbginfo = dbginfo .. j
	if abs(value[4]) > 0.0005 then
		k = tostring(Round(value[4]*1000)/1000)
		if string.sub(k,1,1)!="-" and dbginfo != "" then k = "+"..k end
		k = k .. "k"
	end
	dbginfo = dbginfo .. k
	if dbginfo == "" then dbginfo = "0" end
	return dbginfo
end
class_mt.__tostring = format




--- Returns quaternion <n>*i
function Quat.qi(n)
	return quicknew(0, n or 1, 0, 0)
end

--- Returns <n>*j
function Quat.qj(n)
	return quicknew(0, 0, n or 1, 0)
end

--- Returns <n>*k
function Quat.qk(n)
	return quicknew(0, 0, 0, n or 1)
end




class_mt.__unm = 
function(q)
	return quicknew( -q[1], -q[2], -q[3], -q[4] )
end


class_mt.__add = 
function(lhs, rhs)
	local ltype = type(lhs)
	local rtype = type(rhs)
	
	if ltype == "quaternion" then
		if rtype == "quaternion" then
			return quicknew( lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3], lhs[4] + rhs[4] )
		elseif rtype == "number" then
			return quicknew( lhs[1] + rhs, lhs[2], lhs[3], lhs[4] )
		end
	elseif ltype == "number" and rtype == "quaternion" then
		return quicknew( lhs + rhs[1], rhs[2], rhs[3], rhs[4] )
	end
	
	Error("Tried to add a " .. ltype .. " to a " .. rtype .. "!")
end


class_mt.__sub = 
function(lhs, rhs)
	local ltype = type(lhs)
	local rtype = type(rhs)
	
	if ltype == "quaternion" then
		if rtype == "quaternion" then
			return quicknew( lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4] )
		elseif rtype == "number" then
			return quicknew( lhs[1] - rhs, lhs[2], lhs[3], lhs[4] )
		end
	elseif ltype == "number" and rtype == "quaternion" then
		return quicknew( lhs - rhs[1], -rhs[2], -rhs[3], -rhs[4] )
	end
	
	Error("Tried to subtract a " .. ltype .. " from a " .. rtype .. "!")
end


class_mt.__mul = 
function(lhs, rhs)
	local ltype = type(lhs)
	local rtype = type(rhs)
	
	if ltype == "quaternion" then
		if rtype == "quaternion" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			return quicknew(
				lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
				lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
				lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
				lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
			)
		elseif rtype == "number" then
			return quicknew( lhs[1] * rhs, lhs[2] * rhs, lhs[3] * rhs, lhs[4] * rhs )
		elseif rtype == "Vector" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			local rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3]
			return quicknew(
				-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
				 lhs1 * rhs2 + lhs3 * rhs4 - lhs4 * rhs3,
				 lhs1 * rhs3 + lhs4 * rhs2 - lhs2 * rhs4,
				 lhs1 * rhs4 + lhs2 * rhs3 - lhs3 * rhs2
			)
		end
	elseif rtype == "quaternion" then
		if ltype == "number" then
			return quicknew( lhs * rhs[1], lhs * rhs[2], lhs * rhs[3], lhs * rhs[4] )
		elseif ltype == "Vector" then
			local lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3]
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			return quicknew(
				-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
				 lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
				 lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
				 lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
			)
		end
	end
	
	Error("Tried to multiply a " .. ltype .. " with a " .. rtype .. "!")
end


class_mt.__div = 
function(lhs, rhs)
	local ltype = type(lhs)
	local rtype = type(rhs)
	
	if ltype == "quaternion" then
		if rtype == "quaternion" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			local l = rhs1*rhs1 + rhs2*rhs2 + rhs3*rhs3 + rhs4*rhs4
			return quicknew(
				( lhs1 * rhs1 + lhs2 * rhs2 + lhs3 * rhs3 + lhs4 * rhs4)/l,
				(-lhs1 * rhs2 + lhs2 * rhs1 - lhs3 * rhs4 + lhs4 * rhs3)/l,
				(-lhs1 * rhs3 + lhs3 * rhs1 - lhs4 * rhs2 + lhs2 * rhs4)/l,
				(-lhs1 * rhs4 + lhs4 * rhs1 - lhs2 * rhs3 + lhs3 * rhs2)/l
			)
		elseif rtype == "number" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			return quicknew(
				lhs1/rhs,
				lhs2/rhs,
				lhs3/rhs,
				lhs4/rhs
			)
		end
	elseif rtype == "quaternion" then
		if ltype == "number" then
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			local l = rhs1*rhs1 + rhs2*rhs2 + rhs3*rhs3 + rhs4*rhs4
			return quicknew(
				( lhs * rhs1)/l,
				(-lhs * rhs2)/l,
				(-lhs * rhs3)/l,
				(-lhs * rhs4)/l
			)
		end
	end
	
	Error("Tried to divide a " .. ltype .. " with a " .. rtype .. "!")
end


class_mt.__pow = 
function(lhs, rhs)
	local ltype = type(lhs)
	local rtype = type(rhs)
	
	if ltype == "quaternion" and rtype == "number" then
		if lhs == 0 then return { 0, 0, 0, 0 } end
		local l = log(lhs)
		return qexp({ l*rhs[1], l*rhs[2], l*rhs[3], l*rhs[4] })
	elseif rtype == "quaternion" and ltype == "number" then
		local l = qlog(lhs)
		return qexp({ l[1]*rhs, l[2]*rhs, l[3]*rhs, l[4]*rhs })
	end
	
	Error("Tried to exponentiate a " .. ltype .. " with a " .. rtype .. "!")
end


/******************************************************************************/

class_mt.__eq = 
function(lhs, rhs)
	local ltype = type(lhs)
	local rtype = type(rhs)
	
	if ltype == "quaternion" and rtype == "quaternion" then
		local rvd1, rvd2, rvd3, rvd4 = lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4]
		if rvd1 <= delta && rvd1 >= -delta &&
		   rvd2 <= delta && rvd2 >= -delta &&
		   rvd3 <= delta && rvd3 >= -delta &&
		   rvd4 <= delta && rvd4 >= -delta
		   then return 1 else return 0 end
	end
	
	Error("Tried to compare a " .. ltype .. " with a " .. rtype .. "!")
end

/*
e2function number operator!=(quaternion lhs, quaternion rhs)
	local rvd1, rvd2, rvd3, rvd4 = lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4]
	if rvd1 > delta || rvd1 < -delta ||
	   rvd2 > delta || rvd2 < -delta ||
	   rvd3 > delta || rvd3 < -delta ||
	   rvd4 > delta || rvd4 < -delta
	   then return 1 else return 0 end
end
//*/

/******************************************************************************/

__e2setcost(4)

--- Returns absolute value of <q>
function Quat.abs(q)
	return sqrt(q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
end

--- Returns the conjugate of <q>
function Quat.conj(q)
	return quicknew(q[1], -q[2], -q[3], -q[4])
end

--- Returns the inverse of <q>
function Quat.inv(q)
	local l = q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]
	return quicknew( q[1]/l, -q[2]/l, -q[3]/l, -q[4]/l )
end

--- Returns the real component of the quaternion
function Quat.real(this)
	return this[1]
end

--- Returns the i component of the quaternion
function Quat.i(this)
	return this[2]
end

--- Returns the j component of the quaternion
function Quat.j(this)
	return this[3]
end

--- Returns the k component of the quaternion
function Quat.k(this)
	return this[4]
end

/******************************************************************************/

--- Raises Euler's constant e to the power <q>
function Quat.exp(q)
	return qexp(q)
end

--- Calculates natural logarithm of <q>
function Quat.log(q)
	return qlog(q)
end

--- Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff)
function Quat.qMod(q)
	if q[1]<0 then return quicknew(-q[1], -q[2], -q[3], -q[4]) else return quicknew(q[1], q[2], q[3], q[4]) end
end

--- Performs spherical linear interpolation between <q0> and <q1>. Returns <q0> for <t>=0, <q1> for <t>=1
function Quat.slerp(q0, q1, t)
	local dot = q0[1]*q1[1] + q0[2]*q1[2] + q0[3]*q1[3] + q0[4]*q1[4]
	local q11
	if dot<0 then
		q11 = {-q1[1], -q1[2], -q1[3], -q1[4]}
	else
		q11 = { q1[1], q1[2], q1[3], q1[4] }  -- dunno if just q11 = q1 works
	end

	local l = q0[1]*q0[1] + q0[2]*q0[2] + q0[3]*q0[3] + q0[4]*q0[4]
	if l==0 then return quicknew( 0, 0, 0, 0 ) end
	local invq0 = { q0[1]/l, -q0[2]/l, -q0[3]/l, -q0[4]/l }
	local logq = qlog(qmul(invq0,q11))
	local q = qexp( { logq[1]*t, logq[2]*t, logq[3]*t, logq[4]*t } )
	return qmul(q0,q)
end

/******************************************************************************/

--- Returns vector pointing forward for <this>
function Quat.forward(this)
	local this1, this2, this3, this4 = this[1], this[2], this[3], this[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2
	return Vector(
		this1 * this1 + this2 * this2 - this3 * this3 - this4 * this4,
		t3 * this2 + t4 * this1,
		t4 * this2 - t3 * this1
	)
end

--- Returns vector pointing right for <this>
function Quat.right(this)
	local this1, this2, this3, this4 = this[1], this[2], this[3], this[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2
	return Vector(
		t4 * this1 - t2 * this3,
		this2 * this2 - this1 * this1 + this4 * this4 - this3 * this3,
		- t2 * this1 - t3 * this4
	)
end

--- Returns vector pointing up for <this>
function Quat.up(this)
	local this1, this2, this3, this4 = this[1], this[2], this[3], this[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2
	return Vector(
		t3 * this1 + t2 * this4,
		t3 * this4 - t2 * this1,
		this1 * this1 - this2 * this2 - this3 * this3 + this4 * this4
	)
end

/******************************************************************************/

--- Returns quaternion for rotation about axis <axis> by angle <ang>
function Quat.qRotation(axis, ang)
	local ax = axis
	ax:Normalize()
	local ang2 = ang*deg2rad*0.5
	return quicknew( cos(ang2), ax.x*sin(ang2), ax.y*sin(ang2), ax.z*sin(ang2) )
end

--- Construct a quaternion from the rotation vector <rv1>. Vector direction is axis of rotation, magnitude is angle in degress (by coder0xff)
function Quat.qRotation(rv1)
	local angSquared = rv1.x * rv1.x + rv1.y * rv1.y + rv1.z * rv1.z
	if angSquared == 0 then return quicknew( 1, 0, 0, 0 ) end
	local len = sqrt(angSquared)
	local ang = (len + 180) % 360 - 180
	local ang2 = ang*deg2rad*0.5
	local sang2len = sin(ang2) / len
	return quicknew( cos(ang2), rv1.x * sang2len , rv1.y * sang2len, rv1.z * sang2len )
end

--- Returns the angle of rotation in degrees (by coder0xff)
function Quat.rotationAngle(q)
	local l2 = q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]
	if l2 == 0 then return 0 end
	local l = sqrt(l2)
	local ang = 2*acos(math.Clamp(q[1]/l, -1, 1))*rad2deg  //this returns angle from 0 to 360
	if ang > 180 then ang = ang - 360 end  //make it -180 - 180
	return ang
end

--- Returns the axis of rotation (by coder0xff)
function Quat.rotationAxis(q)
	local m2 = q[2] * q[2] + q[3] * q[3] + q[4] * q[4]
	if m2 == 0 then return Vector( 0, 0, 1 ) end
	local m = sqrt(m2)
	return Vector( q[2] / m, q[3] / m, q[4] / m)
end

--- Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff)
function Quat.rotationVector(q)
	local l2 = q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]
	local m2 = math.max( q[2]*q[2] + q[3]*q[3] + q[4]*q[4], 0 )
	if l2 == 0 or m2 == 0 then return Vector( 0, 0, 0 ) end
	local s = 2 * acos( math.Clamp( q[1] / sqrt(l2), -1, 1 ) ) * rad2deg
	if s > 180 then s = s - 360 end
	s = s / sqrt(m2)
	return Vector( q[2] * s, q[3] * s, q[4] * s )
end

/******************************************************************************/

--- Converts <q> to a vector by dropping the real component
function Quat.vec(q)
	return Vector( q[2], q[3], q[4] )
end

--- Converts <q> to a transformation matrix
/* TODO: this
e2function matrix matrix(quaternion q)
	local w,x,y,z = q[1],q[2],q[3],q[4]
	return {
		1 - 2*y*y - 2*z*z	 , 2*x*y - 2*z*w        , 2*x*z + 2*y*w,
		2*x*y + 2*z*w        , 1 - 2*x*x - 2*z*z	, 2*y*z - 2*x*w,
		2*x*z - 2*y*w        , 2*y*z + 2*x*w        , 1 - 2*x*x - 2*y*y
	}
end
//*/

--- Returns angle represented by <this>
function Quat.toAngle(this)
	local l = sqrt(this[1]*this[1]+this[2]*this[2]+this[3]*this[3]+this[4]*this[4])
	local q1, q2, q3, q4 = this[1]/l, this[2]/l, this[3]/l, this[4]/l

	local x = Vector(q1*q1 + q2*q2 - q3*q3 - q4*q4,
		2*q3*q2 + 2*q4*q1,
		2*q4*q2 - 2*q3*q1)

	local y = Vector(2*q2*q3 - 2*q4*q1,
		q1*q1 - q2*q2 + q3*q3 - q4*q4,
		2*q2*q1 + 2*q3*q4)

	local ang = x:Angle()
	if ang.p > 180 then ang.p = ang.p - 360 end
	if ang.y > 180 then ang.y = ang.y - 360 end

	local yyaw = Vector(0,1,0)
	yyaw:Rotate(Angle(0,ang.y,0))

	local roll = acos(math.Clamp(y:Dot(yyaw), -1, 1))*rad2deg

	local dot = q2*q1 + q3*q4
	if dot < 0 then roll = -roll end

	return Vector(ang.p, ang.y, roll)
end

/******************************************************************************/


function Quat.toString(this)
	return format(this)
end



