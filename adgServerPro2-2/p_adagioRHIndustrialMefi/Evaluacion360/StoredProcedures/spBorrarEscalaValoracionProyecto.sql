USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBorrarEscalaValoracionProyecto](
	 @IDEscalaValoracionProyecto int 
	 ,@IDUsuario int
) as
	declare @IDProyecto int ;

	select @IDProyecto = IDProyecto
	from [Evaluacion360].[tblEscalasValoracionesProyectos]
	where IDEscalaValoracionProyecto = @IDEscalaValoracionProyecto

	begin try
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
	end try
	begin catch
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		return 0;
	end catch

	BEGIN TRY  
		delete [Evaluacion360].[tblEscalasValoracionesProyectos]
		where IDEscalaValoracionProyecto = @IDEscalaValoracionProyecto
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
