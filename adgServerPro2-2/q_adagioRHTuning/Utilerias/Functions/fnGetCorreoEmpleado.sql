USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************************** 
** Descripción		: Busca el valor de una preferencia de usuario
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-04-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2022-11-24			Aneudy Abreu		Se corregió para que buscara el email del usuario en caso
										de que el colaborador no tenga contacto
***************************************************************************************************/
CREATE FUNCTION [Utilerias].[fnGetCorreoEmpleado](	
	@IDEmpleado int = 0,
    @IDUsuario int = 0,
	@IDTipoNotificacion nvarchar(max)= null
)
RETURNS nvarchar(max)
AS
BEGIN
		declare 
			@Value nvarchar(max)
		;
        if (isnull(@IDEmpleado, 0) != 0)
        begin 
            select                       
                @Value=COALESCE(cc.Email,u.Email) 
                From RH.tblEmpleadosMaster  m                
            LEFT JOIN (
                        select ce.IDEmpleado
                            ,lower(ce.[Value]) as Email
                            ,ce.Predeterminado
                            ,ROW_NUMBER()OVER(partition by ce.IDEmpleado order by tt.IDTipoNotificacion desc ,ce.Predeterminado desc) as [ROW]
                            , tt.IDTipoNotificacion
                        from RH.tblContactoEmpleado ce with (nolock)
                            join [RH].[tblCatTipoContactoEmpleado] ctce with (nolock) on ctce.IDTipoContacto = ce.IDTipoContactoEmpleado  and ctce.IDMedioNotificacion = 'email'
                            left join rh.tblContactosEmpleadosTiposNotificaciones tt on tt.IDContactoEmpleado=ce.IDContactoEmpleado AND TT.IDTipoNotificacion=@IDTipoNotificacion
                        where ce.[Value] is not null 
            ) as cc on cc.IDEmpleado=m.IDEmpleado and cc.[ROW]=1  
            left join [Seguridad].[tblUsuarios] u on u.IDEmpleado=m.IDEmpleado
            where m.IDEmpleado=@IDEmpleado
        end

		if (isnull(@Value, '') = '' and isnull(@IDUsuario, 0) != 0)
        begin 
            select @Value=u.Email
		        from Seguridad.tblUsuarios u
		    where u.IDUsuario=@IDUsuario
        end   
		
		return @Value
END
GO
