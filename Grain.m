classdef Grain
    %GRAIN Cette classe repr�sente un objet grain
    %   Elle permet d'am�liorer la lisibilit� du code par rapport � des
    %   tenseurs ou des matrices et utilise les capacit�s de POO de MATLAB
    
    properties
        mass=0.005; %Masse du grain
        radius=0.0006; %Rayon du grain
        position=Pair(0,0); %Coordonn�es du grain
    end
    
    properties (Access = private)
        speed=Pair(0,0); %Vitesse du grain
        half_time_speed=Pair(0,0); %Vitesse de demi temps du grain
        acceleration=Pair(0,0); %Acc�l�ration du grain
        grain_drawing; %Dessin du grain
    end
    
    methods
        function grain = init_position(grain, position_x_0, position_y_0)
            %Fonction pour initialiser la position du grain
            grain.position=Pair(position_x_0, position_y_0);
        end
        
        function grain = draw(grain)
            %Fonction pour dessiner un grain
            
            %Suppresion du dessin de l'ancienne position
            delete(grain.grain_drawing)
            
            %R�cup�ration du facteur utiliser pour mod�liser un grain
            global draw_factor
            
            %Dessin du grain
            grain.grain_drawing=plot(grain.position.x, grain.position.y, '.', 'Markersize', ((grain.radius)*(draw_factor)),'Color','blue');
        end
        
        function grain = compute_position_and_speed(grain)
            %Fonction pour calculer la nouvelle position et la nouvelle
            %vitesse d'un grain en utilisant le sch�ma de Verlet
            
            %R�cup�ration du pas de temps
            global dt
            
            %Calcul de la nouvelle position en x
            grain.position.x=grain.position.x+grain.half_time_speed.x*dt;
            
            %Calcul de la nouvelle position en y
            grain.position.y=grain.position.y+grain.half_time_speed.y*dt;
            
            %Calcul de la nouvelle vitesse en x
            grain.speed.x=grain.half_time_speed.x+grain.acceleration.x*(dt/2);
            
            %Calcul de la nouvelle vitesse en y
            grain.speed.y=grain.half_time_speed.y+grain.acceleration.y*(dt/2);
        end
        
        function grain = compute_acceleration_and_half_time_speed(grain, force)
            %Fonction pour calculer l'acc�l�ration et la vitesse de demi
            %temps pour el sch�ma de Verlet.
            
            %R�cup�ration du pas de temps
            global dt
            
            %Calcul de l'acc�l�ration en x
            grain.acceleration.x=force.x/grain.mass ;
            
            %Calcul de l'acc�l�ration en y
            grain.acceleration.y=force.y/grain.mass ;
        
            %Calcul de la vitesse de demi pas de temps en x
            grain.half_time_speed.x=grain.half_time_speed.x+grain.acceleration.x*dt;
            
            %Calcul de la vitesse de demi pas de temps en y
            grain.half_time_speed.y=grain.half_time_speed.y+grain.acceleration.y*dt;
        end
    end
end

