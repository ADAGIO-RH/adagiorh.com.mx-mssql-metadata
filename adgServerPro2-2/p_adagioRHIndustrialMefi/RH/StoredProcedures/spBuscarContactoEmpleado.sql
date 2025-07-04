USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBuscarContactoEmpleado]
(
     @IDContactoEmpleado int = 0
    ,@IDEmpleado int = 0
    ,@IDUsuario int = 0
)
AS
BEGIN
	declare  
	   @IDIdioma varchar(20)
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	Select 
		CE.IDContactoEmpleado,
		CE.IDEmpleado,
		CE.IDTipoContactoEmpleado,
		JSON_VALUE(TCE.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoContacto,
		CE.Value,
		TCE.Mask,
		TCE.CssClassIcon,
		isnull(ce.Predeterminado,0) as Predeterminado,
		tce.IDMedioNotificacion as IDMedioNotificacion,
		JSON_VALUE(mn.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as MedioNotificacion
	from RH.tblContactoEmpleado CE
		inner join RH.tblCatTipoContactoEmpleado TCE on CE.IDTipoContactoEmpleado = TCE.IDTipoContacto
		left join App.tblMediosNotificaciones mn on tce.IDMedioNotificacion = mn.IDMedioNotificacion
	WHERE (CE.IDEmpleado = @IDEmpleado and @IDContactoEmpleado=0) or (CE.IDContactoEmpleado = @IDContactoEmpleado and @IDEmpleado=0)
	order by ce.IDTipoContactoEmpleado
END
GO
