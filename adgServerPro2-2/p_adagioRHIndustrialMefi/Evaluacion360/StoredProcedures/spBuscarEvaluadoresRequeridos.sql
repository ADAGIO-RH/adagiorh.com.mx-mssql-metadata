USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarEvaluadoresRequeridos](
	@IDEvaluadorRequerido int = 0
	,@IDProyecto int
) as
Declare @IDIdioma VARCHAR(max);
select @IDIdioma = App.fnGetPreferencia('idioma',1,'esmx')

	select 
	er.IDEvaluadorRequerido
	,er.IDProyecto
	,er.IDTipoRelacion
	,JSON_VALUE(ctr.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	,er.Minimo
	,er.Maximo
	from [Evaluacion360].[tblEvaluadoresRequeridos] er
		join  Evaluacion360.tblCatTiposRelaciones ctr on er.IDTipoRelacion = ctr.IDTipoRelacion
	where (er.IDProyecto = @IDProyecto or @IDProyecto = 0) and (er.IDEvaluadorRequerido = @IDEvaluadorRequerido or @IDEvaluadorRequerido = 0)
GO
