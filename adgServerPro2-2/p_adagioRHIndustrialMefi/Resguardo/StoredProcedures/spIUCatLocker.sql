USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Select *
--from [Resguardo].[tblCatLockers]

CREATE proc [Resguardo].[spIUCatLocker](
	 @IDLocker	int = 0
	,@IDCaseta	int 
	,@Codigo	varchar(50)
	,@Disponible	bit 
	,@Activo	bit	 
	,@IDUsuario int
) as
	
	if (@IDLocker = 0)
	begin
		IF EXISTS(Select Top 1 1 
					from [Resguardo].[tblCatLockers] with (nolock)
					where Codigo = @Codigo and IDCaseta = @IDCaseta)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		insert [Resguardo].[tblCatLockers](IDCaseta,Codigo,Disponible,Activo)
		select @IDCaseta,@Codigo,@Disponible,@Activo
	end else
	begin
		IF EXISTS(Select Top 1 1 
					from [Resguardo].[tblCatLockers] with (nolock)
					where Codigo = @Codigo and IDCaseta = @IDCaseta and IDLocker <> @IDLocker)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		update [Resguardo].[tblCatLockers]
			set Codigo = @Codigo
				,Disponible = @Disponible
				,Activo = @Activo
		where IDLocker = @IDLocker
	end;
GO
