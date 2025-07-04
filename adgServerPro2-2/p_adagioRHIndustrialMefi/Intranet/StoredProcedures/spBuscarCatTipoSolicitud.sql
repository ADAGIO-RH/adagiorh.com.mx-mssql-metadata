USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarCatTipoSolicitud] (
    @IDUsuario int=0,
	@SoloIntranet bit=1
)
AS
BEGIN

    declare           @IDIdioma varchar(225);
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

	Select IDTipoSolicitud
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion  
		,Traduccion
		,ISNULL(Intranet,0) as Intranet
		,SPValidaciones
	from Intranet.tblCatTipoSolicitud
	where (Intranet= case when isnull(@SoloIntranet, 0) = 1 then @SoloIntranet else Intranet end) 
END
GO
