clear all;
close all;
format short;

%Pour charger un calcul d�j� r�alis� et ne pas le refaire
load_previous_calculation=false;

%Pour afficher l'animation pendant le calcul true, sinon false
runtime_drawing=false;

%Pour intiliser � des positions al�atoire true, sinon false
random_positions=false;

%Rayon d'un grain de bl� sur le dessin
global draw_factor

%D�finition du pas de temps
global dt

if(load_previous_calculation == true)
    disp("Chargement des variables");
    
    %Chargement des variables
    load('variables_2');
    
    disp("Variables charg�es");

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
    
    disp("Tous les param�tres sont charg�s");

    %Dessin du silo
    draw_silo(y_left,y_right,vertical_silo_radius,flow_silo_radius,vertical_silo_height)
    
    disp("Dessin du silo");
    
    grain_size=size(grain_history);
    
    for t=1:1:grain_size(2)
        for i=1:1:grain_size(1)
            grain_history(i, 1)=redraw(grain_history(i, 1), grain_history(i, t).position.x, grain_history(i, t).position.y);
        end
        drawnow
    end
else
    %D�finition du nombre d'images par seconde
    frames_rate=25;
    
    %D�finition de la masse moyenne d'un grain en kg
    mean_grain_mass=0.00005;
 
    %D�finition du rayon moyen d'un grain en m�tres
    mean_grain_radius=0.002;

    %D�finition de la constante de raideur des parois du silo
    stiffness_silo=100;

    %D�finition de la constante de raideur des grains
    stiffness_grain=100;

    %D�finition de la pesanteur
    g=9.81;

    %Hauteur de la partie verticale du silo
    vertical_silo_height=0.268;

    %Rayon du silo (partie verticale)
    vertical_silo_radius=0.2275;

    %Rayon du silo (partie �coulement)
    flow_silo_radius=0.05;

    %Angle entre la partie oblique par rapport au sol (axe y=0)
    alpha=50*pi/180;

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
    
    %Coefficient d'amortissement des parois silo
    damping_coeff=0.03;

    %Rayon d'un grain de bl� sur le dessin
    draw_factor=7.5/(mean_grain_radius);

    %D�finition du pas de temps
    dt=sqrt(mean_grain_mass/stiffness_silo)/20;

    %D�finition de la dur�e de la simulation
    t_end=2;

    %D�finition du nombre d'it�rations n�cessaires sur le temps
    t_count=round(t_end/dt);

    %D�finition du nombre de grains
    if(random_positions)
        grain_count=1000;
    else
        %Positionnement des grains selon un empilement pr�cis
        grain_space=0.001;
        x_init_max=vertical_silo_radius-grain_space-mean_grain_radius;
        x_init_min=-x_init_max;
        y_init_min=grain_space+mean_grain_radius;
        y_init_max=vertical_silo_height/20-grain_space-mean_grain_radius+flow_silo_height;
        y_init=y_init_max;
        grain_count=0;
        while y_init > y_init_min
            if(y_init >= flow_silo_height)
                x_init=x_init_min;
            else
                x_init=-x_diff(y_init)-flow_silo_radius+grain_space+mean_grain_radius;
                x_init_max=-x_init;
            end
            
            while x_init < x_init_max
                x_init=x_init+2*mean_grain_radius+grain_space;
                grain_count=grain_count+1;
            end
            y_init=y_init-2*mean_grain_radius-grain_space;
         end 
    end
    disp(grain_count);

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
    random_size=randn(1, grain_count);

    %G�n�ration des masses par une distribution normale
    masses=mean_grain_mass+random_size.*0.00001;

    %G�n�ration des rayons par une distribution normale
    radii=mean_grain_radius+random_size.*0.0005;
    if(runtime_drawing == false)
       %Pr� allocation de la m�moire pour la sauvegarde des positions
       grain_history(grain_count, t_end*25)=Grain;
    end
    
    %Compteur de temps entre deux "images"
    elapsed_time_between_frames=floor(t_count / (frames_rate * t_end));

    fprintf('Heure de d�but du cacul: %s\n', datestr(now,'HH:MM:SS.FFF mm/dd/yy'))

    if(random_positions)
        %Boucle sur tous les grains
        for i=1:1:grain_count
            %G�n�ration de la position x du grain i (al�atoire entre le rayon du
            %silo et moins le rayon du silo)
            x_grain_i=(rand-0.5).*(2*vertical_silo_radius);

            %G�n�ration de la position y du grain i (al�atoire entre 0 et la
            %hauteur du silo)
            y_grain_i=(rand.*vertical_silo_height)+flow_silo_height;

            %Initialisation du grain
            grains(i)=init(grains(i),x_grain_i, y_grain_i, masses(i), radii(i));

            %Sauvegarde de la position initiale du grain dans l'historique
            grain_history(i,1)=grains(i);

            if(runtime_drawing == true)
                %Dessin du grain i
                grains(i)=draw(grains(i));
            end
        end
    else
        %Positionnement des grains selon un empilement pr�cis
        grain_space=0.001;
        x_init_max=vertical_silo_radius-grain_space-mean_grain_radius;
        x_init_min=-x_init_max;
        y_init_min=grain_space+mean_grain_radius;
        y_init_max=vertical_silo_height/20-grain_space-mean_grain_radius+flow_silo_height;
        y_init=y_init_max;
        i=1;
        while y_init > y_init_min
            if(y_init >= flow_silo_height)
                x_init=x_init_min;
            else
                x_init=-x_diff(y_init)-flow_silo_radius+grain_space+mean_grain_radius;
                x_init_max=-x_init;
            end
            
            while x_init < x_init_max
                %Initialisation du grain i
                grains(i)=init(grains(i),x_init, y_init, masses(i), radii(i));
                x_init=x_init+2*mean_grain_radius+grain_space;
                i=i+1;
            end
            y_init=y_init-2*mean_grain_radius-grain_space;
        end
        clear x_init
        clear y_init
        clear x_init_max
        clear y_init_max
        clear x_init_min
        clear y_init_min
        clear grain_space
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
            if grains(i).position.y >= -0.05
                grains(i)=compute_position_and_speed(grains(i));
            end
        end
        
        %True si l'on doit sauvegarder l'image sinon false
        display_frame=(mod(t, elapsed_time_between_frames) == 0);
        
        %Boucle sur tous les grains
        for i=1:1:grain_count
            %Coordonn�es du grain i
            x_grain_i=grains(i).position.x;
            y_grain_i=grains(i).position.y;
            r_grain=grains(i).radius;

            if y_grain_i < -0.05
                if display_frame        
                    %Sauvegarde de la position du grain
                    grain_history(i,t / elapsed_time_between_frames)=grains(i);
                end
                continue;
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
                if x_grain_i + r_grain >= flow_silo_radius && y_right(x_grain_i + r_grain) >= y_grain_i + r_grain
                    %Contact paroi droite
                    diff_y=y_right(x_grain_i+r_grain)-y_grain_i-r_grain;
                    force_i.x=force_i.x-x_diff(diff_y)*stiffness_silo-grains(i).speed.x*damping_coeff;
                    force_i.y=force_i.y+diff_y*stiffness_silo-grains(i).speed.y*damping_coeff;
                elseif x_grain_i + r_grain <= -flow_silo_radius && y_left(x_grain_i + r_grain) >= y_grain_i + r_grain
                    %Contact paroi gauche
                    diff_y=y_left(x_grain_i+r_grain)-y_grain_i-r_grain;
                    force_i.x=force_i.x+x_diff(diff_y)*stiffness_silo-grains(i).speed.x*damping_coeff;
                    force_i.y=force_i.y+diff_y*stiffness_silo-grains(i).speed.y*damping_coeff;
                elseif x_grain_i + r_grain > vertical_silo_radius
                    %Contact paroi verticale droite
                    force_i.x=force_i.x+(vertical_silo_radius-x_grain_i-r_grain)*stiffness_silo;
                elseif x_grain_i - r_grain < -vertical_silo_radius
                    %Contact paroi verticale gauche
                    force_i.x=force_i.x+(-x_grain_i-r_grain-vertical_silo_radius)*stiffness_silo;
                end
            end

            %Calcul de la position du grain
            grains(i)=compute_acceleration_and_half_time_speed(grains(i), force_i);
            
            if(display_frame)
                if(runtime_drawing == true)
                    %Dessin du grain i
                    grains(i)=draw(grains(i));
                else
                    %Sauvegarde de la position du grain
                    grain_history(i,t / elapsed_time_between_frames)=grains(i);
                end
            end
        end

        if(display_frame)
            fprintf('Avancement %.2f %%\n', (100 * t/t_count));
            if((mod(t, elapsed_time_between_frames*25) == 0))
                %Sauvegarde des variables
                save('variables_1', 'grain_history', 'draw_factor', 'vertical_silo_height', 'vertical_silo_radius', 'flow_silo_radius', 'alpha', 'damping_coeff');
                disp("Sauvegarde des variables effectu�e");
            end
        end
        if(runtime_drawing == true)
            %Dessin de cet instant t
            drawnow
        end
    end

    fprintf('Heure de fin de calcul: %s\n', datestr(now,'HH:MM:SS.FFF mm/dd/yy'))
end


if(runtime_drawing == false && load_previous_calculation == false)
    %Sauvegarde des variables
    save('variables_2', 'grain_history', 'draw_factor', 'vertical_silo_height', 'vertical_silo_radius', 'flow_silo_radius', 'alpha', 'damping_coeff');
    disp("Sauvegarde des variables effectu�e");
end

disp("Ex�cution r�ussie et termin�e.");