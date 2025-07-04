USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar el detalle un Wizard de Usuario
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-20
** Paremetros		:              

exec [Evaluacion360].[spBuscarDetalleWizardUsuario] 
	@IDWizardUsuario  = 1
	,@IDUsuario = 1

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
 CREATE proc [Evaluacion360].[spBuscarDetalleWizardUsuario] (
	@IDWizardUsuario int = 0
	,@IDUsuario int
 ) as
	declare  
		@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@IDItemCompetencias int = 4;

	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;

	select 
		 dwu.IDDetalleWizardUsuario
		,dwu.IDWizardUsuario
		,wu.IDProyecto
		,dwu.IDWizardItem
		,cw.Item
		,cw.Descripcion
		,[Url] = case 
					when cw.IDWizardItem = @IDItemCompetencias then cw.[Url]+'?tiporeferencia=1&idreferencia='+cast(wu.IDProyecto as varchar(10)) 
					else cw.[Url] 
					end
		,cw.Orden
		,dwu.Completo
		,dwu.FechaHora
		,LEFT(DATENAME(WEEKDAY,isnull(dwu.FechaHora,getdate())),3) + ' ' +
			  CONVERT(VARCHAR(6),isnull(dwu.FechaHora,getdate()),106) 
			  + ' '+convert(varchar(4),datepart(year,isnull(dwu.FechaHora,getdate()) ))
				FechaHoraStr
		,cw.[JSONData]
	from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock) 
		join [Evaluacion360].[tblWizardsUsuarios] wu with (nolock) on dwu.IDWizardUsuario = wu.IDWizardUsuario
		join [Evaluacion360].[tblCatWizardItem] cw with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	where dwu.IDWizardUsuario = @IDWizardUsuario
	order by cw.Orden asc
GO
