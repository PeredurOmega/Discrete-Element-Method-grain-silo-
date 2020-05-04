%Masse moyenne d'un grain de bl�
m = 0.005;
%Rayon moyen d'un grain de bl�
r = 0.0006;

%Rayon du silo (partie verticale)
Rsv = 2;
%Rayon du silo (partie �coulement)
Rse = 0.1;

%Angle entre la partie oblique par rapport au sol (axe y=0).
alpha = pi/4;

%Nous consid�rons que le centre du silo se situe � x=0 et que � y=0 se
%trouve la sortie du silo (partie o� l'on mesure le d�bit d'�coulement).

%Ainsi la paroi oblique droite va de Rse � Rsv en x et de 0 �
%(Rsv-Rse)/cos(alpha) en y. Et la paroi de gauche va de -Rse � -Rsv en x
%et de 0 � (Rse-Rsv)/cos(alpha) en y.
yDroite = @(x) (x-Rse)*tan(alpha);
yGauche = @(x) (-x-Rse)*tan(alpha);

%Pesanteur terrestre.
g=9.81;

%Initialisation des param�tres de temps.
t0=0;
dt=0.01;
tf=2;
t=(t0:dt:tf);
Npas=(tf-t0)/dt;

%D�termination des contacts avec les parois obliques.
%Position grain.
positionGrain = zeros(2,Npas);
vitesseGrain = zeros(2,Npas);

positionGrain(1,1) = 0;
positionGrain(2,1) = 3;

vitesseGrain(1,1) = 0;
vitesseGrain(2,1) = 0;

%Dessin du silo.
fplot(yGauche, [-Rsv -Rse],'Color','red'); 
hold on
fplot(yDroite, [Rse Rsv],'Color','red'); 
hold on
line([Rsv Rsv], [yDroite(Rsv) yDroite(Rsv)+5],'Color','red')
hold on
line([-Rsv -Rsv], [yGauche(-Rsv) yGauche(-Rsv)+5],'Color','red')
hold on
grid
axis equal

%Dessin du grain � l'intitialisation.
grainDrawing = plot(positionGrain(1,1), positionGrain(2,1), '.', 'Markersize', 15,'Color','blue');

for i=1:Npas
    xGrain=positionGrain(1,i);
    yGrain=positionGrain(2,i);
    vX=vitesseGrain(1,i);
    vY=vitesseGrain(2,i);

    if(xGrain >= Rse && yDroite(xGrain) >= yGrain)
        disp('Contact paroi Droite');
    elseif(xGrain <= -Rse && yGauche(xGrain) >= yGrain)
        disp('Contact paroi Gauche');
    elseif(xGrain >= Rsv)
        disp('Contact paroi verticale Droite');
    elseif(xGrain <= -Rsv)
        disp('Contact paroi verticale Gauche');
    end
    
    %Aplication de la pesanteur.
    positionGrain(2,i+1)=yGrain+dt*(vitesseGrain(2,i));
    vitesseGrain(2,i+1)=vY+dt*(-g);
    
    %Dessin du grain.
    delete(grainDrawing);
    grainDrawing = plot(positionGrain(1,i+1), positionGrain(2,i+1), '.', 'Markersize', 15,'Color','blue');
    hold on
    drawnow
end






