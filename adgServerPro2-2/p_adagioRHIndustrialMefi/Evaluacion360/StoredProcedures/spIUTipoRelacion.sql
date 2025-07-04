USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Insertar / Actualizar Tipos de Relaciones
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-25
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spIUTipoRelacion](
	 @IDTipoRelacion int
	,@Codigo varchar(20) 
	,@Relacion varchar(255)  
	,@Traduccion varchar(max)  
	,@IDUsuario int
 ) as
	select @Codigo = UPPER(@Codigo)
		, @Relacion = UPPER(@Relacion)

	IF(@IDTipoRelacion = 0 OR @IDTipoRelacion Is null)
	BEGIN
		  IF EXISTS(Select Top 1 1 from [Evaluacion360].[tblCatTiposRelaciones] where Codigo = @Codigo)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [Evaluacion360].[tblCatTiposRelaciones]([Codigo],Relacion,Traduccion)
		VALUES (@Codigo,@Relacion,@Traduccion)

		set @IDTipoRelacion = @@IDENTITY

		exec [Evaluacion360].[spBuscarTiposRelaciones] @IDTipoRelacion=@IDTipoRelacion
	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from [Evaluacion360].[tblCatTiposRelaciones]  where Codigo = @Codigo and IDTipoRelacion <> @IDTipoRelacion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		UPDATE [Evaluacion360].[tblCatTiposRelaciones]
		   SET [Codigo] = @Codigo
			  ,Relacion = @Relacion
			  ,Traduccion = @Traduccion
		 WHERE IDTipoRelacion= @IDTipoRelacion

		exec [Evaluacion360].[spBuscarTiposRelaciones] @IDTipoRelacion=@IDTipoRelacion
	END
GO
