function quat = euler2quat(euler)

% quat = euler2quat(euler)
%
% Compute the quaternions given the attitude in Euler angles
% Inputs:
%   euler = the 3x1 vector of Euler angles (roll, pitch, yaw)
% Outputs:
%   quat = the 4x1 vector of quaternions (e0, ex, ey, ez)

phi = euler(1);
theta = euler(2);
psi = euler(3);

e0 = cos(phi/2)*cos(theta/2)*cos(psi/2)+sin(phi/2)*sin(theta/2)*sin(psi/2);
ex = sin(phi/2)*cos(theta/2)*cos(psi/2)-cos(phi/2)*sin(theta/2)*sin(psi/2);
ey = cos(phi/2)*sin(theta/2)*cos(psi/2)+sin(phi/2)*cos(theta/2)*sin(psi/2);
ez = cos(phi/2)*cos(theta/2)*sin(psi/2)-sin(phi/2)*sin(theta/2)*cos(psi/2);

quat = [e0; ex; ey; ez];