USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [App].[spBuscarComentarios](
	 @IDComentario		int	= 0	
	,@IDTipoComentario	int	= 0	
	,@IDReferencia		int	= 0	
	,@IDUsuario			int		
) as

	declare 
		@dtUsuarios [Seguridad].[dtUsuarios]
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@EsNorma35 bit = 0
		,@DenunciaAnonima bit = 0
	;

	SET DATEFIRST 7;

	IF(@IDTipoComentario = 2)
	BEGIN
		set @EsNorma35 = 1

		Select @DenunciaAnonima = isnull(EsAnonima,0) 
		from Norma35.tblDenuncias with(nolock) 
		where IDDenuncia = @IDReferencia
	END

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;

	insert @dtUsuarios
	exec [Seguridad].[spBuscarUsuarios]
	
	select 
		cp.IDComentario
		,cp.IDReferencia
		,cp.IDTipoComentario
		,cp.Comentario
		,cp.IDUsuario
		, CASE WHEN @EsNorma35 = 0 THEN u.ClaveEmpleado
			ELSE
				CASE WHEN @EsNorma35 = 1 and @DenunciaAnonima = 1 and isnull(u.IDUsuario,0) <> @IDUsuario  THEN '0000'
					ELSE u.ClaveEmpleado
				END
			END as ClaveEmpleado
		,CASE WHEN @EsNorma35 = 0 THEN coalesce(u.Nombre,'')+ ' '+coalesce(u.Apellido,'') 
			ELSE
				CASE WHEN @EsNorma35 = 1 and @DenunciaAnonima = 1 and isnull(u.IDUsuario,0) <> @IDUsuario  THEN 'ANONIMO'
					ELSE coalesce(u.Nombre,'')+ ' '+coalesce(u.Apellido,'')
				END
			END NombreUsuario
		,cp.FechaHora
		,FechaHoraStr = case 
							when (DATEDIFF(HOUR,cp.FechaHora,getdate()) = 0) and (DATEDIFF(MINUTE,cp.FechaHora,getdate()) < 10) then 'Hace un momento'
							when (DATEDIFF(HOUR,cp.FechaHora,getdate()) = 0) and (DATEDIFF(MINUTE,cp.FechaHora,getdate()) >= 10) then 'hace '+cast(DATEDIFF(MINUTE,cp.FechaHora,getdate()) as VARCHAR)+ ' minutos.'
							when (DATEDIFF(DAY, cp.FechaHora,getdate()) = 0) and (DATEDIFF(HOUR,  cp.FechaHora,getdate()) = 1) then 'hace una hora'
							when (DATEDIFF(DAY, cp.FechaHora,getdate()) = 0) and (DATEDIFF(HOUR,  cp.FechaHora,getdate()) > 1) then 'hace '+cast(DATEDIFF(HOUR,cp.FechaHora,getdate()) as VARCHAR)+ ' horas.'
							when (DATEDIFF(WEEK,cp.FechaHora,getdate()) = 0) and (DATEDIFF(DAY,   cp.FechaHora,getdate()) = 1) then 'hace un día'
							when (DATEDIFF(WEEK,cp.FechaHora,getdate()) = 0) and (DATEDIFF(DAY ,  cp.FechaHora,getdate()) > 1) then 'hace '+cast(DATEDIFF(DAY,cp.FechaHora,getdate()) as VARCHAR)+ ' días.'
							when (DATEDIFF(MONTH,cp.FechaHora,getdate()) = 0) and (DATEDIFF(WEEK, cp.FechaHora,getdate()) = 1) then 'hace una semana.'
							when (DATEDIFF(MONTH,cp.FechaHora,getdate()) = 0) and (DATEDIFF(WEEK, cp.FechaHora,getdate()) > 1) then 'hace '+cast(DATEDIFF(WEEK,cp.FechaHora,getdate()) as VARCHAR)+ ' semanas. ('+cast(cp.FechaHora as varchar)+')'
							when (DATEDIFF(MONTH,cp.FechaHora,getdate()) < 12) and (DATEDIFF(MONTH,cp.FechaHora,getdate()) = 1) then 'hace un mes. ('+cast(cp.FechaHora as varchar)+')'
							when (DATEDIFF(MONTH,cp.FechaHora,getdate()) < 12) and (DATEDIFF(MONTH,cp.FechaHora,getdate()) > 1) then 'hace '+cast(DATEDIFF(MONTH,cp.FechaHora,getdate()) as VARCHAR)+ ' meses. ('+cast(cp.FechaHora as varchar)+')'
							when (DATEDIFF(MONTH,cp.FechaHora,getdate()) = 12) then 'hace un año. ('+cast(cp.FechaHora as varchar)+')'
							when (DATEDIFF(YEAR,cp.FechaHora,getdate()) > 1) then 'hace '+cast(DATEDIFF(YEAR,cp.FechaHora,getdate()) as VARCHAR)+ ' años. ('+cast(cp.FechaHora as varchar)+')'
					    END
	from  [App].[tblComentarios] cp
		inner join @dtUsuarios u on cp.IDUsuario = u.IDUsuario
	where (cp.IDComentario = @IDComentario or @IDComentario = 0)
		and (cp.IDTipoComentario = @IDTipoComentario or @IDTipoComentario = 0)
		and (cp.IDReferencia = @IDReferencia )
	order by cp.FechaHora desc
GO
