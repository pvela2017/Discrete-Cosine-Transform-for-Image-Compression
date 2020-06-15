%compresion mediante dct

clear all
close all
clc

n=8; %dimensión de los bloques

imagen_rgb=imread('lena_std.tif'); %captura de la imagen en rgb
imagen_grises=rgb2gray(imagen_rgb); %transformacion de la imagen de rgb a escala de grises

figure()
imshow(imagen_grises)%plot imagen original
title('Imagen en escala de grises')

a1=n*ones(1,64);

imagen_grises=im2double(imagen_grises);%se transforman los bits a double

B=mat2cell(imagen_grises,a1,a1);%se divide la imagen en bloques de 8x8

for i=1:64
    for j=1:64
        C{i,j}=dct2(B{i,j}); %se obtiene la dct2 de cada bloque de 8x8
    end
end

imagendct=cell2mat(C); %dct de la imagen
figure()
imshow(imagendct)%plot dct de la imagen
title('DCT de la imagen original')

D=zeros(8,8,4096);
z=1;

for i=1:64
    for j=1:64
             D(:,:,z)=C{i,j}; %se extraen los bloques
             z=z+1;
    end
end


suma=zeros(8,8,1);
for k=1:4096
    suma=suma+D(:,:,k);%se suman los bloques para formar un bloque de 8x8
end
    
[ordenada,index]=sort(suma(:),'descend'); %se ordenan los coeficientes de mayor a menor tamaño


%RECONSTRUCCION

numero=1; %numero de coeficientes

bloque=zeros(8);


for coef=1:numero %se guardan los coeficientes en las matrices
    col=ceil(index(coef,1)/8);
    fila=rem(index(coef,1),8);
    if fila==0
        fila=8;
    end
    for z=1:4096
        bloque(fila,col,z)=D(fila,col,z);
    end
end


z=1;
for i=1:64
    for j=1:64
             C{i,j}=idct2(bloque(:,:,z)); %se extraen los bloques
             z=z+1;
    end
end

imagenfinal=zeros(512);
imagenfinal=cell2mat(C);

figure()
imshow(imagenfinal)
title(['Imagen restaurada con ' ,num2str(numero),' coeficientes'])
    
    
%Error

 err=abs(imagen_grises-imagenfinal).^2;
 MSE = sum(err(:))/numel(imagen_grises);
 
 figure()
 imshow(err)
 title('Error de la imagen restaurada')
 
 
 %Filtrado
filtrogaus=fspecial('gaussian',[8 8],5);%filtro gausiano
filtrada=imfilter(imagenfinal,filtrogaus,'replicate');
    
filtrosha= fspecial('unsharp');%filtro sharp
filtrada=imfilter(filtrada,filtrosha,'replicate');
    
figure()
imshow(filtrada)
title('Imagen restaurada filtrada')