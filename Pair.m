classdef Pair
    %PAIR Cette classe est utilis�e pour am�liorer la lisibilit� du code
    %et tirer profit de la POO sur MATLAB
    %   Cette classe repr�sente un couple (x,y)
    
    properties
        x
        y
    end
    
    methods
        function pair = Pair(x_0,y_0)
            %PAIR Constructeur d'un couple de coordonn�es (x,y)
            pair.x=x_0;
            pair.y=y_0;
        end
    end
end

