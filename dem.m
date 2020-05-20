clear all;
close all;
format short;

%Pour afficher l'animation pendant le calcul true, sinon false
runtime_drawing=false;

%Pour charger un calcul d�j� r�alis� et ne pas le refaire
load_previous_calculation=true;

if(load_previous_calculation == true)
    disp("Chargement des variables");
    
    %Chargement des variables
    saved_variables = matfile('position_history.mat');
    
    disp("Variables charg�es");
    
    %Hauteur de la partie verticale du silo
    vertical_silo_height=saved_variables.vertical_silo_height;

    %Rayon du silo (partie verticale)
    vertical_silo_radius=saved_variables.vertical_silo_radius;

    %Rayon du silo (partie �coulement)
    flow_silo_radius=saved_variables.flow_silo_radius;

    %Angle entre la partie oblique par rapport au sol (axe y=0)
    alpha=saved_variables.alpha;
    
    disp("Premiers param�tres charg�s");

    %Nous consid�rons que le centre du silo se situe � x=0 et que � y=0 se
    %trouve la sortie du silo (partie o� l'on mesure le d�bit d'�coulement)

    %Ainsi la paroi oblique droite va de Rse � Rsv en x et de 0 �
    %(Rsv-Rse)/cos(alpha) en y. Et la paroi de gauche va de -Rse � -Rsv en x
    %et de 0 � (Rse-Rsv)/cos(alpha) en y
    y_right = @(x) (x-flow_silo_radius)*tan(alpha);
    y_left = @(x) (-x-flow_silo_radius)*tan(alpha);
    x_diff = @(y_diff) y_diff/tan(alpha);

    %Hauteur de la paroi oblique
    flow_silo_height=y_right(vertical_silo_radius);

    %Rayon d'un grain de bl� sur le dessin
    global draw_factor
    draw_factor=saved_variables.draw_factor;

    %D�finition du pas de temps
    global dt
    dt=saved_variables.dt;

    %D�finition de la dur�e de la simulation
    t_end=saved_variables.t_end;
    
    disp("Touls les param�tres sont charg�s");

    %Dessin du silo
    draw_silo(y_left,y_right,vertical_silo_radius,flow_silo_radius,vertical_silo_height)
    
    disp("Dessin du silo");
    
    %R�cup�ration de l'historique des positions
    grain_position_history=saved_variables.grain_position_history;
    
    disp("Fin du chargement de l'historique");
    
    grain_size=size(grain_position_history);
    
    drawings=zeros(1,grain_size(1));
    
    for t=1:1:grain_size(2)
        for i=1:1:grain_size(1)
            if t ~= 1
                delete(drawings(i));
            end
            drawings(i)=plot(grain_position_history(i,t).x, grain_position_history(i,t).y, '.', 'Markersize', 15,'Color','blue');
        end
        drawnow
    end
else
    %D�finition de la masse moyenne d'un grain en kg
    mean_grain_mass=0.00005;
 
    %D�finition du rayon moyen d'un grain en m�tres
    mean_grain_radius=0.006;

    %D�finition de la constante de raideur des parois du silo
    stiffness_silo=1000;

    %D�finition de la constante de raideur des grains
    stiffness_grain=1000;

    %D�finition de la pesanteur
    g=9.81;

    %Hauteur de la partie verticale du silo
    vertical_silo_height=5;

    %Rayon du silo (partie verticale)
    vertical_silo_radius=2;

    %Rayon du silo (partie �coulement)
    flow_silo_radius=0.1;

    %Angle entre la partie oblique par rapport au sol (axe y=0)
    alpha=pi/4;

    %Nous consid�rons que le centre du silo se situe � x=0 et que � y=0 se
    %trouve la sortie du silo (partie o� l'on mesure le d�bit d'�coulement)

    %Ainsi la paroi oblique droite va de Rse � Rsv en x et de 0 �
    %(Rsv-Rse)/cos(alpha) en y. Et la paroi de gauche va de -Rse � -Rsv en x
    %et de 0 � (Rse-Rsv)/cos(alpha) en y
    y_right = @(x) (x-flow_silo_radius)*tan(alpha);
    y_left = @(x) (-x-flow_silo_radius)*tan(alpha);
    x_diff = @(y_diff) y_diff/tan(alpha);

    %Hauteur de la paroi oblique
    flow_silo_height=y_right(vertical_silo_radius);

    %Rayon d'un grain de bl� sur le dessin
    global draw_factor
    draw_factor=15/(mean_grain_radius);

    %D�finition du pas de temps
    global dt
    dt=sqrt(mean_grain_mass/stiffness_silo)/20;

    %D�finition de la dur�e de la simulation
    t_end=10;

    %D�finition du nombre d'it�rations n�cessaires sur le temps
    t_count=round(t_end/dt);

    %D�finition du nombre de grains
    grain_count=2;

    %D�finition de la p�riode de mise � jour des voisinages
    update_period=10;

    %D�finition du "rayon de voisinage"
    r_vicinity=0.5*g*(update_period*dt)^2;

    %D�finition du nombre maximum de voisins
    neighboors_count=10;

    %Initialisation de la matrice des voisins
    %-1 signifie qu'il n'y a pas de voisins
    neighboors=-1.*ones(1,neighboors_count,grain_count);

    if(runtime_drawing == true)
        %Dessin du silo
        draw_silo(y_left,y_right,vertical_silo_radius,flow_silo_radius,vertical_silo_height)
    end

    % D�finition de l'�tat initial des grains et dessin de leur �tat �
    % l'initialisation
    grains(grain_count)=Grain;

    %G�n�ration des tailles des grains selon une distribution normale
    random_size = randn(1, grain_count);

    %G�n�ration des masses par une distribution normale
    masses=mean_grain_mass+random_size.*0.00001;

    %G�n�ration des rayons par une distribution normale
    radii=mean_grain_radius+random_size.*0.001;
    if(runtime_drawing == false)
       %Pr� allocation de la m�moire pour la sauvegarde des positions
       grain_position_history(grain_count, t_count)=struct('x', 0, 'y', 0);
    end

    fprintf('Heure de d�but du cacul: %s\n', datestr(now,'HH:MM:SS.FFF mm/dd/yy'))

    %Boucle sur tous les grains
    for i=1:1:grain_count
        %G�n�ration de la position x du grain i (al�atoire entre le rayon du
        %silo et moins le rayon du silo)
        x_grain_i=(rand-0.5).*(2*vertical_silo_radius);

        %G�n�ration de la position y du grain i (al�atoire entre 0 et la
        %hauteur du silo)
        y_grain_i=(rand.*vertical_silo_height)+flow_silo_height;

        %Initialisation du grain
        grains(i)=init(grains(i),x_grain_i, x_grain_i, masses(i), radii(i));

        %Sauvegarde de la position initiale du grain dans l'historique
        grain_position_history(i,1).x=x_grain_i;
        grain_position_history(i,1).y=y_grain_i;

        if(runtime_drawing == true)
            %Dessin du grain i
            grains(i)=draw(grains(i));
        end
    end

    %Supression des variables inutiles
    clear masses;
    clear radii;
    clear random_size;

    %Boucle principale en fonction du temps
    for t=2:1:t_count
        %Boucle sur tous les grains
        for i=1:1:grain_count
            %Calcul de la nouvelle position et de la nouvelle vitesse du grain
            %i
            grains(i)=compute_position_and_speed(grains(i));
        end

        %Boucle sur tous les grains
        for i=1:1:grain_count
            %Coordonn�es du grain i
            x_grain_i=grains(i).position.x;
            y_grain_i=grains(i).position.y;
            r_grain=grains(i).radius;

            if y_grain_i < -0.5
               continue 
            end

            %Mise � jour des voisinages
            if update_period==t || t==1
                %R�initialisation des voisinages pour le grain i
                neighboors(:,:,i)=-1.*ones(1,neighboors_count);

                %Initialisation du compteur de voisins de i
                neighboors_i_count=0;

                %Ajout des voisins
                j = 1;
                while j<=grain_count && neighboors_i_count < neighboors_count
                    %Coordonn�es du grain j
                    x_grain_j=grains(j).position.x;
                    y_grain_j=grains(j).position.y;

                    if j==i || y_grain_j < -0.5
                        %Incr�mentation du compteur
                        j=j+1;
                        continue;
                    end

                    %V�rification du voisinage
                    if (abs(x_grain_j-x_grain_i) <= r_vicinity || abs(y_grain_j-y_grain_i) <= r_vicinity)
                        %Ajout en tant que voisin
                        neighboors(:,neighboors_i_count+1,i)=j;

                        %Incr�mentation du nombre de voisins
                        neighboors_i_count=neighboors_i_count+1;
                    end

                    %Incr�mentation du compteur
                    j=j+1;
                end
            end

            %Application des efforts � distance (la pesanteur...)
            force_i=Pair(0,-grains(i).mass*g);

            %Boucle sur tous les grains appartenant � la liste des voisins de i
            k=1;
            while 1
                %Initialisation du voisin k
                neighboor=neighboors(k);

                %Si il n'y a pas de voisin � la position k -> arr�t de la
                %boucle
                if neighboor == -1
                    break;
                end

                %Coordonn�es du grain j (voisin / neighboor)
                x_grain_j=grains(neighboor).position.x;
                y_grain_j=grains(neighboor).position.y;

                %Calcul de la diff�rence de distance entre les voisins
                diff_x=x_grain_i-x_grain_j;
                diff_y=y_grain_i-y_grain_j;

                %Application des forces de contacts en x sur i
                if abs(diff_x) < r_grain
                    if diff_x < 0
                        force_i.x=force_i.x+stiffness_grain*diff_x;
                    else
                        force_i.x=force_i.x+stiffness_grain*diff_x;
                    end
                end  

                %Application des forces de contacts en y sur i
                if abs(diff_y) < r_grain
                    if diff_y < 0
                        force_i.y=force_i.y+stiffness_grain*diff_y;
                    else
                        force_i.y=force_i.y+stiffness_grain*diff_y;
                    end
                end

                %Incr�mentation de la boucle
                k=k+1;

                %Si tous les voisins ont �t� contr�l�s -> arr�t de la boucle
                if k>neighboors_count
                    break;
                end
            end

            %D�termination des contacts avec la paroi du silo
            if y_grain_i > 0
                if x_grain_i >= flow_silo_radius && y_right(x_grain_i) >= y_grain_i
                    %Contact paroi droite
                    diff_y=y_right(x_grain_i)-y_grain_i;
                    force_i.x=force_i.x-x_diff(diff_y)*stiffness_silo;
                    force_i.y=force_i.y+diff_y*stiffness_silo;
                elseif x_grain_i <= -flow_silo_radius && y_left(x_grain_i) >= y_grain_i
                    %Contact paroi gauche
                    diff_y=y_left(x_grain_i)-y_grain_i;
                    force_i.x=force_i.x+x_diff(diff_y)*stiffness_silo;
                    force_i.y=force_i.y+diff_y*stiffness_silo;
                elseif x_grain_i > vertical_silo_radius
                    %Contact paroi verticale droite
                    force_i.x=force_i.x+(vertical_silo_radius-x_grain_i)*stiffness_silo;
                elseif x_grain_i < -vertical_silo_radius
                    %Contact paroi verticale gauche
                    force_i.x=force_i.x+(-x_grain_i-vertical_silo_radius)*stiffness_silo;
                end
            end

            %Calcul de la position du grain
            grains(i)=compute_acceleration_and_half_time_speed(grains(i), force_i);

            if(runtime_drawing == true)
                %Dessin du grain i
                grains(i)=draw(grains(i));
            else           
                %Sauvegarde de la position du grain
                grain_position_history(i,t).x=x_grain_i;
                grain_position_history(i,t).y=y_grain_i;
            end
        end

        if(runtime_drawing == true)
            %Dessin de cet instant t
            drawnow
        end
        
        if(mod(t,100) == 0)
            fprintf('Avancement %.2f %%\n', (100 * t/t_count))
        end
    end

    fprintf('Heure de fin de calcul: %s\n', datestr(now,'HH:MM:SS.FFF mm/dd/yy'))
end


if(runtime_drawing == false && load_previous_calculation == false)
    save position_history.mat grain_position_history dt draw_factor t_end vertical_silo_height vertical_silo_radius flow_silo_radius alpha -v7.3;
    %Sauvegarde de l'historique des positions
    saved_variables = matfile('position_history.mat','Writable',true);
    saved_variables.grain_position_history = grain_position_history;
    saved_variables.dt = dt;
    saved_variables.draw_factor = draw_factor;
    saved_variables.t_end = t_end;
    saved_variables.vertical_silo_height = vertical_silo_height;
    saved_variables.vertical_silo_radius = vertical_silo_radius;
    saved_variables.flow_silo_radius = flow_silo_radius;
    saved_variables.alpha = alpha;
    
    disp("Sauvegarde des variables effectu�e");
end

disp("Ex�cution r�ussie et termin�e.");