USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	 SP PARA DESASIGNAR AL EMPLEADO DE LA POSISICON
-- =============================================
CREATE PROCEDURE [RH].[spBorrarAsignacionPosicion]
    @IDUsuario int,
    @IDPosicion int     
AS
BEGIN
	declare  
		@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE INT = 2,
		@IDPlaza int
    ;

	select @IDPlaza = IDPlaza
	from RH.tblCatPosiciones
    where IDPosicion = @IDPosicion

    BEGIN TRY
		BEGIN TRAN AsignarColaboradorAPosicion

            declare @IDEmpleado int;
            declare @IDOrganigrama int;

            select @IDEmpleado= IDEmpleado,@IDOrganigrama=IDOrganigrama from RH.tblCatPosiciones   po WITH(NOLOCK) 
            inner join rh.tblCatPlazas pp on  pp.IDPlaza=po.IDPlaza
           where IDPosicion=@IDPosicion;

            update RH.tblCatPosiciones 
                set
                    IDEmpleado = null
            where IDPosicion = @IDPosicion
				
            insert RH.tblEstatusPosiciones(IDPosicion, IDEstatus, IDUsuario, IDEmpleado)
            select @IDPosicion,@ESTATUS_POSICION_AUTORIZADA_DISPONIBLE,@IDUsuario,null

            EXEC [RH].[spAsignarJefeEmpleadosByIDOrganigrama] @IDOrganigrama=@IDOrganigrama;

            -- Actualizar relación jefes empleados de los subordinados

            -- exec [RH].[spActualizarJefesEmpleadosSubordinados] @IDPosicion=@IDPosicion;
            -- exec [RH].[spAsignarJefesEmpleadosOrganigramaIndividual] @IDPosicion=@IDPosicion


            
            


            --- QUITAR EL JEFE EMPLEADO ACTUAL EN BASE A LA CONFIGURACIÓN
            DECLARE @tblConfiguracion as Table(
                IDTipoConfiguracionPlaza varchar(100),
                Valor int,
                Descripcion varchar(100)
            );
            declare @ConfiguracionJson varchar(max);
	
            Select 		 
                @ConfiguracionJson = pl.Configuraciones
	        from RH.tblCatPosiciones P with(nolock)
		    INNER  join RH.tblCatPlazas pl with(nolock) on p.IDPlaza = pl.IDPlaza
	        WHERE p.IDPosicion = @IDPosicion

            insert into @tblConfiguracion(IDTipoConfiguracionPlaza,Valor, Descripcion)
            SELECT i.IDTipoConfiguracionPlaza, i.[Valor], i.[Descripcion]
            FROM OPENJSON(@ConfiguracionJson) WITH (
            IDTipoConfiguracionPlaza varchar(100) '$.IDTipoConfiguracionPlaza',
            Valor int '$.Valor',
            Descripcion varchar(100) '$.Descripcion'
            ) AS i
	

            declare @IDJefe int
            SELECT @IDJefe = IDEmpleado                 
                from RH.tblCatPosiciones WITH(NOLOCK)
            WHERE IDPosicion = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'PosicionJefe')
                        
            DELETE RH.tblJefesEmpleados
            WHERE IDEmpleado = @IDEmpleado and IDJefe=@IDJefe
            

			COMMIT TRANSACTION AsignarColaboradorAPosicion
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION; 
		DECLARE @MESSAGE VARCHAR(max) =  ERROR_MESSAGE(),
			@SEVERITY VARCHAR(max) =  ERROR_SEVERITY(),
			@STATE VARCHAR(max) =  ERROR_STATE();			
		RAISERROR(  
			@MESSAGE
			,@SEVERITY
			,@STATE );
        
	END CATCH;

END
GO
