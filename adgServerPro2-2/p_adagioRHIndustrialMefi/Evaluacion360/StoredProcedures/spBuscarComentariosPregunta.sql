USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Evaluacion360].[spBuscarComentariosPregunta](
	 @IDComentarioPregunta	int	= 0	
	,@IDPregunta			int	= 0	
	,@IDUsuario				int		
) as

	declare 
		@dtUsuarios [Seguridad].[dtUsuarios]
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

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

	insert @dtUsuarios
	exec [Seguridad].[spBuscarUsuario]
	
	select 
		cp.IDComentarioPregunta
		,cp.IDPregunta
		,cp.Comentario
		,cp.IDUsuario
		,u.ClaveEmpleado
		,coalesce(u.Nombre,'')+ ' '+coalesce(u.Apellido,'') NombreUsuario
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
	from  [Evaluacion360].[tblComentariosPregunta] cp
		inner join @dtUsuarios u on cp.IDUsuario = u.IDUsuario
	where (cp.IDComentarioPregunta = @IDComentarioPregunta or @IDComentarioPregunta = 0)
		and (cp.IDPregunta = @IDPregunta or @IDPregunta = 0)
	order by cp.FechaHora desc
GO
