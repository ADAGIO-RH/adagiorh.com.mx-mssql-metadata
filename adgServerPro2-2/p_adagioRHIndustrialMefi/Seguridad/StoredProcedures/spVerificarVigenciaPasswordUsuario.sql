USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Verifica la caducidad del password del usuario
** Autor			: ? (Jose Vargas)
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-07-08
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------`
***************************************************************************************************/

CREATE   proc [Seguridad].[spVerificarVigenciaPasswordUsuario](
	@IDUsuario int
)
as
begin
	begin try

        declare @jsonstring NVARCHAR(max)
        select @jsonstring=Valor from app.tblConfiguracionesGenerales  where IDConfiguracion='SeguridadPasswordLogin'    
        declare @tempConfiguracion as table (
            clave NVARCHAR(MAX),
            valor NVARCHAR(MAX)
        );
        INSERT INTO @tempConfiguracion (clave, valor)
        SELECT [key], value FROM OPENJSON(@jsonstring);
 
        
         declare @vigencia int,
				@validar_caducidad_password varchar(20);
          select @vigencia=valor from @tempConfiguracion where clave='dias_vigencia_password'          
          select @validar_caducidad_password=valor from @tempConfiguracion where clave='validar_caducidad_password'          

		declare @Today datetime = getdate()
		declare @UltimaFechaActualizacion datetime = (select top 1 UltimaFechaActualizacion 
															from [Seguridad].[tblHistorialPasswordsUsuarios] 
															where IDUsuario = @IDUsuario
															order by UltimaFechaActualizacion desc)
		declare @diferencia int = DATEDIFF(day, @UltimaFechaActualizacion, @Today)

		-- declare @vigencia int = cast([App].[fnGetConfiguracionGeneral]('DiasVigenciaPassword', @IDUsuario, '90') as int)

		if(@diferencia > @vigencia and isnull(@validar_caducidad_password,'false') = 'true')
		begin
			select 'Tu contraseña ha caducado, por favor actualizala' as Mensaje,
			0 as CodeVigenciaPassword
			return 0
		end
		else
			select 'Contraseña valida' as Mensaje,
			1 as CodeVigenciaPassword
			return 1
	end try
	begin catch
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
	
end
GO
