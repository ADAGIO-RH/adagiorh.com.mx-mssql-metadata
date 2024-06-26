USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUDetalleEscalaValoracion](
	@IDDetalleEscalaValoracion	int	 = 0
	,@IDEscalaValoracion	int	 
	,@Nombre	varchar	(100)
	,@Valor	int 
	,@IDUsuario int
) as 
	set @Nombre = UPPER(@Nombre);

	if (@IDDetalleEscalaValoracion = 0)
	begin
		IF EXISTS(Select Top 1 1 
					from [Evaluacion360].[tblDetalleEscalaValoracion] 
					where IDEscalaValoracion = @IDEscalaValoracion and
						 (Nombre = @Nombre or Valor = @Valor))
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003',@CustomMessage= 'El Nombre y el Valor no se puede repetir.'
			RETURN 0;
		END;
		 
		insert into [Evaluacion360].[tblDetalleEscalaValoracion](IDEscalaValoracion,Nombre,Valor)
		select @IDEscalaValoracion,@Nombre,@Valor
		
		select @IDDetalleEscalaValoracion = @@IDENTITY 
	end else
	begin
		IF EXISTS(Select Top 1 1 
					from [Evaluacion360].[tblDetalleEscalaValoracion] 
					where IDEscalaValoracion = @IDEscalaValoracion and
						 (Nombre = @Nombre or Valor = @Valor) and IDDetalleEscalaValoracion <> @IDDetalleEscalaValoracion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003',@CustomMessage= 'El Nombre y el Valor no se puede repetir.'
			RETURN 0;
		END;

		update [Evaluacion360].[tblDetalleEscalaValoracion] 
			set Nombre = @Nombre	
				,Valor = @Valor
		where IDDetalleEscalaValoracion = @IDDetalleEscalaValoracion
	end;

	exec [Evaluacion360].[spBuscarDetalleEscalaValoracion] @IDDetalleEscalaValoracion = @IDDetalleEscalaValoracion
GO
