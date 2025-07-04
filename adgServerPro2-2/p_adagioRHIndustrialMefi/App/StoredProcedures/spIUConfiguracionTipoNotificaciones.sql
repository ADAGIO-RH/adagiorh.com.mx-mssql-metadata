USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Modificar el correo default de la tipos de notificaciones
** Autor			: Jose Vargas
** Email			: jvargas@adagiorh.com.mx
** FechaCreacion	: 2023-08-22
** Paremetros		:              
    @IsSpecial
        0           : no especiales
        1           : especiales
        null o -1   : trae todos 
        
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROC [App].[spIUConfiguracionTipoNotificaciones] 
(
    @IDTipoNotificacion	varchar(50) ,
    @IDTipoConfiguracionNotificacion int,
    -- @Valor varchar(50),
    @IDUsuario  int
) as

    if( exists(select top 1 1 from APP.tblConfiguracionTiposNotificaciones where IDTipoNotificacion = @IDTipoNotificacion))
    BEGIN
        
        UPDATE APP.tblConfiguracionTiposNotificaciones 
        set IDTipoConfiguracionNotificacion=@IDTipoConfiguracionNotificacion
        WHERE  IDTipoNotificacion = @IDTipoNotificacion
    end
    else 
    begin
        insert into APP.tblConfiguracionTiposNotificaciones  (IDTipoNotificacion,IDTipoConfiguracionNotificacion)
        values(@IDTipoNotificacion,@IDTipoConfiguracionNotificacion)
    end
GO
