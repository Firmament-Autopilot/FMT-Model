classdef VehicleState < Simulink.IntEnumType
    % MATLAB enumeration class definition generated from template
    %   to track the active leaf state of FMS/FMS State Machine/Vehicle.
    
    enumeration
        None(0),
		Disarm(1),
		Standby(2),
		Offboard(3),
		Mission(4),
		InvalidAutoMode(5),
		Hold(6),
		Acro(7),
		Stabilize(8),
		Altitude(9),
		Position(10),
		InvalidAssistMode(11),
		Manual(12),
		InValidManualMode(13),
		InvalidArmMode(14),
		Land(15),
		Return(16),
		Takeoff(17)
    end

    methods (Static)

        function defaultValue = getDefaultValue()
            % GETDEFAULTVALUE  Returns the default enumerated value.
            %   If this method is not defined, the first enumeration is used.
            defaultValue = VehicleState.None;
        end

        function dScope = getDataScope()
            % GETDATASCOPE  Specifies whether the data type definition should be imported from,
            %               or exported to, a header file during code generation.
            dScope = 'Auto';
        end

        function desc = getDescription()
            % GETDESCRIPTION  Returns a description of the enumeration.
            desc = 'enumeration to track active leaf state of FMS/FMS State Machine/Vehicle';
        end

        function fileName = getHeaderFile()
            % GETHEADERFILE  Returns path to header file if non-empty.
            fileName = '';
        end

        function flag = addClassNameToEnumNames()
            % ADDCLASSNAMETOENUMNAMES  Indicate whether code generator applies the class name as a prefix
            %                          to the enumeration.
            flag = true;
        end

    end

end
