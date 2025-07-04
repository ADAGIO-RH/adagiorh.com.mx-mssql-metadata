USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarQuienRespondePregunta](
	@IDPregunta int
) as
DECLARE @IDIdioma VARCHAR(max)
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	select 
	 isnull(qrp.IDQuienResponderaPregunta,0) as IDQuienResponderaPregunta
	,isnull(qrp.IDPregunta,0) as IDPregunta
	,ctp.IDTipoRelacion
	,ctp.Codigo
    ,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	,Chk = case 
	
		when ctp.IDTipoRelacion = 5 and @IDPregunta = 0 then cast(1 as bit) 
		when qrp.IDTipoRelacion is null then cast(0 as bit) else cast(0 as bit) 
	
	end
	from [Evaluacion360].tblCatTiposRelaciones ctp 
		left join [Evaluacion360].[tblQuienResponderaPregunta] qrp  on qrp.IDTipoRelacion = ctp.IDTipoRelacion
	where qrp.IDPregunta = @IDPregunta
GO
