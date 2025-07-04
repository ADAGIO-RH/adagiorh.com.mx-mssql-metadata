USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtener la url del empleado. 
Para evitar problemas de lentitud de la carga de imagen, esta función retona la urr para que sea mejor.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-07-01
** Paremetros		:              
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------        
***************************************************************************************************/
CREATE function [Utilerias].[fnGetUrlFotoUsuario]
(
	@ClaveUsuario Varchar(Max)
)
returns Varchar(Max)
AS
BEGIN
    DECLARE @UrlFoto varchar(max)
    select 
    @UrlFoto=case when fe.IDEmpleado is not null 
                then CONCAT('Fotos/Empleados/',fe.ClaveEmpleado,'.jpg') 
                when fu.IDUsuario is not null 
                then CONCAT('Fotos/Usuarios/',fu.IDUsuario,'.jpg') 
                else
                    'Fotos/nofoto.jpg'
                end 
    from Seguridad.tblUsuarios u 
    left join Seguridad.tblFotoUsuarios fu on u.IDUsuario=u.IDUsuario
    left join rh.tblFotosEmpleados fe on fe.IDEmpleado=u.IDEmpleado
    where u.Cuenta=@ClaveUsuario

    set @UrlFoto= case when @UrlFoto IS NULL THEN 'Fotos/nofoto.jpg' ELSE @UrlFoto END;
        
	return @UrlFoto
END
GO
