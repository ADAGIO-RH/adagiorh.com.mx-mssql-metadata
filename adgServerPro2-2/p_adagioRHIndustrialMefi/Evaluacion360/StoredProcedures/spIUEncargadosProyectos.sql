USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [d_adagioRH]
--GO
--/****** Object:  StoredProcedure [Evaluacion360].[spIUEncargadosProyectos]    Script Date: 29/01/2019 12:08:04 p. m. ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE proc [Evaluacion360].[spIUEncargadosProyectos](
	@IDEncargadoProyecto int
	,@IDProyecto int
	,@IDCatalogoGeneral int
	,@Nombre varchar(255)  
	,@Email varchar(255)
	,@IDUsuario int
	,@IDsCatalogoGeneral varchar(255) = '1|2|3'
) as
--declare 
--	@IDEncargadoProyecto int = 0
--	,@IDProyecto int = 63
--	,@IDCatalogoGeneral int
--	,@Nombre varchar(255)  = 'Aneudy Abreu'
--	,@Email varchar(255) = 'aneudy.abreu@adagio.com.mx'
--	,@IDUsuario int
--	,@IDsCatalogoGeneral varchar(255) = '1|2|3'

	 


	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	select @Nombre = UPPER(@Nombre)
	
	if (@IDEncargadoProyecto = 0)
	begin
		insert into  [Evaluacion360].[tblEncargadosProyectos](IDProyecto,IDCatalogoGeneral,Nombre,Email)
		select @IDProyecto,item as IDCatalogoGeneral,@Nombre,@Email
		from App.Split(@IDsCatalogoGeneral,'|')
		--select @IDProyecto,@IDCatalogoGeneral,@Nombre,@Email

		select @IDEncargadoProyecto = @@IDENTITY
	end else
	begin
		update [Evaluacion360].[tblEncargadosProyectos]
		 set IDCatalogoGeneral = @IDCatalogoGeneral
			,Nombre = @Nombre
			,Email = @Email
		where IDEncargadoProyecto = @IDEncargadoProyecto
	end;

	exec [Evaluacion360].[spBuscarEncargadosProyectos] @IDEncargadoProyecto = @IDEncargadoProyecto
GO
