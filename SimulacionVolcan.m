clc;
clearvars;
close all;

%constantes
den_aire = 1.225; %kg/m3
den_roca = 2360;  %kg/m3
cd = input("Ingrese el coeficiente de arrastre: "); %coeficiente de arrastre
altura = 3763;    %metros = yn
dt = 0.5;         %transurso del tiempo
g = 9.81;         %m/s2
proyectiles={1,3};

%Crear volcan
crater = 50;
base = 4000;
x1 = [-base, -crater, -crater, -base];
y1 = [0, altura, 0, 0];
x2 = [-crater, crater, crater, -crater, -crater];
y2 = [0, 0, altura, altura, 0];
x3 = [crater, base, crater, crater];
y3 = [0, 0, altura, 0];

%Este for genera las matrices correspondientes a cada proyectil. Las
%columnas son: xn, yn, vx, vy, ax, ay, ||v||, ||a||, escogeAngulo 
for k=1:3

    %Datos de Entrada 
    fprintf("¿Qué velocidad inicial desea que tenga el proyectil %d? ",k)
    vi = input("");%297.5 * rand + 2.5;
    radio = 3* rand;

    %Angulos
    fprintf("¿Qué ángulo de lanzamiento desea para el proyectil %d? ",k)
    anguloReal = input(""); %60*rand + 10;
    escogeAngulo= randi([1,2]);

    %Datos de proceso
    vol = (4/3) * pi * (radio^3);
    masa = den_roca * vol;
    area = pi * radio^2;
    vix = vi * cosd(anguloReal);
    viy = vi * sind(anguloReal);
    xn = 0;
    yn=altura;
    xn_menos1 = xn-vix*dt;
    yn_menos1 = yn-viy*dt-0.5*g*dt^2;

    %Funciones
    b = 0.5 * cd * den_aire * area;   %Coeficiente de Friccion

    %Procesos
    proyectil1=[];
    proyectil1(1,1)=0;
    proyectil1(1,2)=altura;
    proyectil1(1,3)=vix;
    proyectil1(1,4)=viy;
    proyectil1(1,5)= -(vix/abs(vix))*(b*(vix^2)/masa);%(b*(vix^2))/masa;
    proyectil1(1,6)=(-g)-(viy/(abs(viy))) * (b*(viy^2)/masa);
    proyectil1(1,9)=escogeAngulo;
    control1=2;

    %este while calcula los valores de la matriz hasta que el proyectil
    %choca con el piso.
    while yn >= 0
       aceleracion_x = -(vix/abs(vix))*(b*(vix^2)/masa);%(b*(vix^2))/masa ;% 
       aceleracion_y = (-g)-(viy/(abs(viy))) * (b*(viy^2)/masa);

       %Predecir valores siguientes
       xn_mas1 = 2*xn - xn_menos1 +  aceleracion_x * dt^2; %2*xn - xn_menos1 +  0.5*aceleracion_x * dt^2;
       yn_mas1 = 2*yn - yn_menos1 +  aceleracion_y * dt^2; %2*yn - yn_menos1 +  0.5*aceleracion_y * dt^2;

       %Refrescar valores de velocidad en 'x' y 'y'
       vix = (xn_mas1 - xn)/dt;%(xn-xn_menos1)/dt;
       viy = (yn_mas1 - yn)/dt;%(yn-yn_menos1)/dt;

       %aquí se cambia de lado del volcan de manera aleatoria
       if escogeAngulo == 1
           proyectil1(control1,1)=xn;
       else
           proyectil1(control1,1)=-xn;
       end

       %guardo todo en mi matriz, usando el contador para num fila
       proyectil1(control1,2)=yn;
       proyectil1(control1,3)=vix;
       proyectil1(control1,4)=viy;
       proyectil1(control1,5)=aceleracion_x;
       proyectil1(control1,6)=aceleracion_y;
       proyectil1(control1,7)=sqrt(vix^2+viy^2);
       proyectil1(control1,8)=sqrt(aceleracion_x^2+aceleracion_y^2);
       control1=control1+1;
       
       %Reasignar valores de xn, xn_mas1 y yn, yn_mas1
       xn_menos1 = xn;
       xn = xn_mas1;

       yn_menos1 = yn;
       yn = yn_mas1;
    end

   
    proyectiles{1,k}=proyectil1;
end

%Obtener axis en x
xmax=[];
for m=1:3
    if proyectiles{1,m}(1,9)==1
        if max(proyectiles{1,1}(:,1))> max(proyectiles{1,2}(:,1))
            if max(proyectiles{1,1}(:,1))> max(proyectiles{1,3}(:,1))
                xmax(m) = max(proyectiles{1,1}(:,1));
            else
                xmax(m) = max(proyectiles{1,3}(:,1));
            end
        elseif  max(proyectiles{1,2}(:,1))>max(proyectiles{1,3}(:,1))
                xmax(m) = max(proyectiles{1,2}(:,1));
            else
                xmax(m) = max(proyectiles{1,3}(:,1));
        end
   else
        if min(proyectiles{1,1}(:,1))< min(proyectiles{1,2}(:,1))
            if min(proyectiles{1,1}(:,1))< min(proyectiles{1,3}(:,1))
                xmax(m) = abs(min(proyectiles{1,1}(:,1)));
            else
                xmax(m) = abs(min(proyectiles{1,3}(:,1)));
            end
        elseif  min(proyectiles{1,2}(:,1))< min(proyectiles{1,3}(:,1))
                xmax(m) = abs(min(proyectiles{1,2}(:,1)));
            else
                xmax(m) = abs(min(proyectiles{1,3}(:,1)));
        end
    end
end    

%obtener axis en y
if max(proyectiles{1,1}(:,2))> max(proyectiles{1,2}(:,2))
    if max(proyectiles{1,1}(:,2))> max(proyectiles{1,3}(:,2))
        ymax = max(proyectiles{1,1}(:,2));
    else
        ymax = max(proyectiles{1,3}(:,2));
    end
elseif  max(proyectiles{1,2}(:,2))>max(proyectiles{1,3}(:,2))
    ymax = max(proyectiles{1,2}(:,2));
else
    ymax = max(proyectiles{1,3}(:,2));
end

%Grafica los valores en la matriz
for j=1:3
    for i=1:length(proyectiles{1,j})
    fill(x1,y1,[0.5,.25,0]);
    hold on
    fill(x2,y2,'r');
    hold on
    fill(x3,y3,[.50,.25,0]); 
    hold on
    title ("Modelación Volcán de Fuego");
    xlabel("Desplazamiento (m)");
    ylabel("Altura (m)");
    hold on
    plot(proyectiles{1,j}(i,1),proyectiles{1,j}(i,2), '.r');
    valorx = {'x:',proyectiles{1,j}(i,1)};
    valory = {'y:',proyectiles{1,j}(i,2)};
    magnitudV={'||v||:', proyectiles{1,j}(i,7)};
    magnitudA={'||a||:', proyectiles{1,j}(i,8)};
    text(proyectiles{1,j}(i,1)+100,proyectiles{1,j}(i,2)+850,valorx)
    text(proyectiles{1,j}(i,1)+100,proyectiles{1,j}(i,2)+150,valory)
    text(-max(xmax)+10,ymax-600,magnitudV)
    text(-max(xmax)+10,ymax-1400,magnitudA)
    axis([-max(xmax)-1000,max(xmax)+1000,0,ymax+2000]);
    pause(0.001)
    hold off
    end
    if j==1
        reporte1={"Primer proyectil:","||v|| final:", proyectiles{1,j}(i,7),"||a|| final:",proyectiles{1,j}(i,8),"Desplazamiento",proyectiles{1,j}(i,1)};
    elseif j==2
        reporte2={"Segundo proyectil:","||v|| final:", proyectiles{1,j}(i,7),"||a|| final:",proyectiles{1,j}(i,8),"Desplazamiento",proyectiles{1,j}(i,1)};
    else
        reporte3={"Tercer proyectil","||v|| final:", proyectiles{1,j}(i,7),"||a|| final:",proyectiles{1,j}(i,8),"Desplazamiento",proyectiles{1,j}(i,1)};
    end    
end

%finalmente, imprimo las cajas de texto que guardaron mis valores finales.
primeraCaja=annotation('textbox',[0.31 0.8 0.1 0.1],'String',reporte1,'FitBoxToText','on');
primeraCaja.FontSize= 8;
segundaCaja=annotation('textbox',[0.5 0.8 0.1 0.1],'String',reporte2,'FitBoxToText','on');
segundaCaja.FontSize= 8;
terceraCaja=annotation('textbox',[0.71 0.8 0.1 0.1],'String',reporte3,'FitBoxToText','on');
terceraCaja.FontSize= 8;
stringAuxilio={"Evacuar a todos","en un radio de:", max(xmax),"metros"};
cajaAuxilio=annotation('textbox',[0.71 0.45 0.1 0.1],'String',stringAuxilio,'FitBoxToText','on');
cajaAuxilio.FontSize=8;
cajaAuxilio.Color='red';