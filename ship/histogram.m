clc ;close all;clear;
I=imread('build.bmp');%读取图片
tempmax=0;%找最大值临时变量
pos=0;%此时灰度位置
khist=1.5;%均衡程度系数
J=rgb2gray(I);%灰度化
I1=histeq(J);%自带均衡
figure(1);
subplot(321)
imshow(J)
title('原始图像')
subplot(322)
h=imhist(J);
imhist(J)
title('原始直方图')
subplot(323)
%现实原始图像
Jmat=histeq(J);

imshow(Jmat);
title('自动灰度直方图均衡')


subplot(324)
imhist(Jmat);%计算直方图
%bar(he)%绘制直方图
title('灰度直方图结果')
%imshow(h)
[m,n]=size(J);
b=find(h>(50), 1, 'last' );%找到最大的不为阈值的灰度位置
c=find(h>(50) , 1 );%找到最小的不为阈值的灰度位置
k=zeros(1,256);
k0=zeros(1,256);
for i=2:256%正向计算斜率
   k(i)=(h(i)-h(1))/(i-1); 
end
[~,locMp]=max(k);%找到最大值与位置
Mp=h(locMp);
for i=1:b-1%反向计算斜率
   k0(i)=-(h(i)-h(b))/(i-b); 
end
[~,locNp]=max(k0);%找到最大值与位置
Np=h(locNp);
kl=(Np-Mp)/(locNp-locMp);%L斜率

for i=locMp:locNp
    L=Mp+kl*(i-locMp);
   rd=L-h(i);
   if rd>tempmax
       tempmax=rd;
       pos=i;
   end
end
const1=log( (pos/khist+1))/pos;%计算指数系数
const2=9/(255-pos);
const3=1-pos*const2;
J0=double(J);
for i=1:m
    for j=1:n
        if J0(i,j)<=pos
            J0(i,j)=floor(exp((J0(i,j)*const1))-1);
        else 
           J0(i,j)=pos/khist+(255-pos/khist)*log10((const2*J0(i,j)+const3));
        end
    end
end
ret=uint8(J0);
subplot(325)
imshow(ret,[])
title('改进灰度直方图均衡')
h0=imhist(ret);%计算直方图
subplot(326)
imhist(ret)%绘制直方图
title('灰度直方图结果')

[g,~]=find(h0(1:floor(pos/khist))~=0);%不为0的序列
G=h0(g);%剔除0后数组
%LN0=length(g);%非0单元个数
[~,peaksloc]=findpeaks(G);
K=length(peaksloc);%极大值个数
S=zeros(K+2,1);
S(2:K+1)=G(peaksloc);
S(1)=G(1);
S(K+2)=G(end);
T1=mean(S);%高阈值


[g,~]=find(h0(floor(pos/khist)+1:256)>0);%不为0的序列
%[g0,~]=find(h0(28:256)>0);
M=h0(g+floor(pos/khist));%剔除0后数组
%LN0=length(g);% 非0单元个数
[~,peaksloc]=findpeaks(256-M);
K1=length(peaksloc);%极大值个数
N=zeros(K1+2,1);
N(2:K1+1)=M(peaksloc);
N(1)=M(1);
N(K1+2)=M(end);
T2=mean(N);%低阈值