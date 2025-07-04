USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Salud].[spBuscarPruebaARealizar](
	@IDCuestionario int,
	@IDEmpleado int,
	@IDUsuario int
) as
	declare
		@IDPrueba int,
		@IDPruebaEmpleado int,
		@IDCuestionarioEmpleado int,
		@IDIdioma Varchar(5),
		@IdiomaSQL varchar(100) = null,
		@ConfiguracioSemaforo VARCHAR(MAX)

	;

	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u with (nolock)
	   Inner join App.tblPreferencias p with (nolock)
		  on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp with (nolock)
		  on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp with (nolock)
		  on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	   where u.IDUsuario = @IDUsuario
		  and tp.TipoPreferencia = 'Idioma'

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	select top 1 
		@IDCuestionario = IDCuestionario 
		,@IDPrueba = IDReferencia
	from Salud.tblCuestionarios with (nolock)
	where IDCuestionario = @IDCuestionario

	select top 1 @IDPruebaEmpleado = IDPruebaEmpleado
	from [Salud].[tblPruebasEmpleados] with (nolock)
	where IDPrueba = @IDPrueba and IDEmpleado = @IDEmpleado

	SELECT @ConfiguracioSemaforo ='['+ STUFF(
						( select ','+ a.JSON
						from Salud.[tblConfiguracionSemaforo] b							
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
						where b.IDCuestionario = @IDCuestionario
						FOR xml path('')

						)
						, 1
						, 1
						, ''
									)
						+']'

	if (isnull(@IDPruebaEmpleado,0) = 0)
	begin
		insert Salud.tblPruebasEmpleados(IDPrueba,IDEmpleado,IDUsuario)
		select @IDPrueba,@IDEmpleado,@IDUsuario

		set @IDPruebaEmpleado = @@IDENTITY
	end

	insert into Salud.tblCuestionariosEmpleados(IDPruebaEmpleado,IDUsuario,ConfiguracioSemaforo)
	select @IDPruebaEmpleado, @IDUsuario,@ConfiguracioSemaforo

	set @IDCuestionarioEmpleado = @@IDENTITY

	exec [Salud].[spCopiarCuestionario] @IDCuestionario	 = @IDCuestionario
										,@TipoReferencia = 2
										,@IDReferencia	 = @IDCuestionarioEmpleado
										,@IDUsuario		 = @IDUsuario

	select @IDCuestionarioEmpleado IDCuestionarioEmpleado											
	--select 
	--	ce.IDCuestionarioEmpleado
	--	,ce.IDPruebaEmpleado
	--	,ce.IDUsuario
	--	,pe.IDPrueba
	--	,pe.IDEmpleado
	--	,c.IDCuestionario
	--	,c.Nombre as Cuestionario
	--	,c.Descripcion DescripcionCuestionario
	--	,c.TipoReferencia
	--	,c.IDReferencia
	--	,c.isDefault
	--	,s.IDSeccion
	--	,s.Nombre as Seccion
	--	,s.Descripcion as DescripcionSeccion
	--	,p.IDPregunta
	--	,p.IDTipoPregunta
	--	,p.Descripcion as Pregunta
	--	,p.Calificar
	--	,p.MaximaCalificacionPosible
	--	,isnull(pr.IDPosibleRespuesta,0) as IDPosibleRespuesta
	--	,pr.OpcionRespuesta
	--	,isnull(pr.Valor,0) as Valor	
	--from [Salud].[tblCuestionariosEmpleados] ce with (nolock)
	--	join [Salud].[tblPruebasEmpleados] pe with (nolock) on pe.IDPruebaEmpleado = ce.IDPruebaEmpleado
	--	join [Salud].[tblCuestionarios] c with (nolock) on c.IDReferencia = ce.IDCuestionarioEmpleado and c.TipoReferencia = 2
	--	join [Salud].[tblSecciones] s with (nolock) on s.IDCuestionario = c.IDCuestionario
	--	join [Salud].[tblPreguntas] p with (nolock) on p.IDSeccion = s.IDSeccion
	--	left join [Salud].[tblPosiblesRespuestasPreguntas] pr with (nolock) on pr.IDPregunta = pr.IDPregunta
	--where IDCuestionarioEmpleado = @IDCuestionarioEmpleado
GO
