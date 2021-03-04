%Problem 1
n = 5000 ;
t = linspace(0,20*pi,n);
x = sin(t).*(exp(cos(t))-2*cos(4*t)+sin(t/12).^5)
y = cos(t).*(exp(cos(t))-2*cos(4*t)+sin(t/12).^5)
subplot(131);plot(t,x,'k'); 
hold on;
plot(t,y,'r-.');
title('x and y vs. t')
xlabel('t') 
ylabel('x and y')
legend('x vs. t','y vs. t');
hold off;
subplot(132),plot(x,y,'r');
title('y vs. x')
xlabel('x') 
ylabel('y') 
%Problem 2
n = pi/32;
theta = 0:n:8*pi;
rho = (exp(sin(theta))-2*cos(4*theta)-(sin((20-pi)/24).^5))
subplot(133),polar(theta,rho,'--r')
title('Butterfly Curve')
xlabel('Theta (\theta)')