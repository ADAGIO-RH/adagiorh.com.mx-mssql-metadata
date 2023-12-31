USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar un Wizard de Usuario
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-20
** Paremetros		:   
						@IDWizardUsuario int = 0
						,@SoloCompletos bit = null
						,@IDUsuario int           
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2021-08-12			ANEUDY ABREU	- Validación del permiso @VER_TODAS_LAS_PRUEBAS
									- Se agregó el campo Usuario


[Evaluacion360].[spBuscarWizardUsuario] 
	@IDWizardUsuario  = 0
--	,@SoloCompletos  = 1
	,@IDUsuario = 1
***************************************************************************************************/
 CREATE proc [Evaluacion360].[spBuscarWizardUsuario] (
	@IDWizardUsuario int = 0
	,@SoloCompletos bit = null
	,@IDUsuario int
 ) as

	begin -- Set Idioma
 		declare  
			@IDIdioma Varchar(5)
			,@IdiomaSQL varchar(100) = null
		;

		SET DATEFIRST 7;

		select top 1 @IDIdioma = dp.Valor
		from Seguridad.tblUsuarios u with (nolock)
			inner join App.tblPreferencias p with (nolock) on u.IDPreferencia = p.IDPreferencia
			inner join App.tblDetallePreferencias dp with (nolock) on dp.IDPreferencia = p.IDPreferencia
			inner join App.tblCatTiposPreferencias tp with (nolock) on tp.IDTipoPreferencia = dp.IDTipoPreferencia
		where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'

		select @IdiomaSQL = [SQL]
		from app.tblIdiomas
		where IDIdioma = @IDIdioma

		if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
		begin
			set @IdiomaSQL = 'Spanish' ;
		end
  
		SET LANGUAGE @IdiomaSQL;
	end

	declare 
		@VER_TODAS_LAS_PRUEBAS bit = 0
	;      
	
	if exists(
		select top 1 1 
		from Seguridad.tblPermisosEspecialesUsuarios pes with (nolock)	
			join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'VER_TODAS_LAS_PRUEBAS')
	begin
		set @VER_TODAS_LAS_PRUEBAS = 1
	end;

	select 
		wu.IDWizardUsuario
		,wu.IDProyecto
		,cp.Nombre Proyecto
		,isnull(cp.Descripcion,'SIN DESCRIPCIÓN') as DescripcionProyecto
		,wu.IDUsuario
		,coalesce(u.Nombre, '')+ ' '+ coalesce(u.Apellido, '') as Usuario
		,wu.Completo
		,[Evaluacion360].[fnBuscarProgresoWizardUsuario](wu.IDWizardUsuario) as Progreso
		,wu.FechaHora 
		,LEFT(DATENAME(WEEKDAY,isnull(wu.FechaHora,getdate())),3) + ' ' +
			CONVERT(VARCHAR(6),isnull(wu.FechaHora,getdate()),106) 
			+ ' '+convert(varchar(4),datepart(year,isnull(wu.FechaHora,getdate()) ))
			FechaHoraStr
	from [Evaluacion360].[tblWizardsUsuarios] wu with (nolock)
		join [Evaluacion360].[tblCatProyectos] cp with (nolock) on wu.IDProyecto = cp.IDProyecto
		join [Seguridad].[tblUsuarios] u on u.IDUsuario = wu.IDUsuario
	where (wu.IDWizardUsuario = @IDWizardUsuario or @IDWizardUsuario = 0)
		and (wu.IDUsuario = case when @VER_TODAS_LAS_PRUEBAS = 1 then wu.IDUsuario else @IDUsuario end)
		and (wu.Completo = isnull(@SoloCompletos,0))
	order by wu.FechaHora asc
GO
