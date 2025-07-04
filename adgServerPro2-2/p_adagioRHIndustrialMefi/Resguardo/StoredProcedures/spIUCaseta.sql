USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Resguardo].[spIUCaseta](
	@IDCaseta int  = 0
	,@Nombre varchar(100) 
	,@Activa bit 
	,@TotalLockers int = 0
	,@IDUsuario int
) AS
	set @Nombre = UPPER(@Nombre)
	if (@IDCaseta = 0)
	begin
		insert [Resguardo].[tblCatCasetas](Nombre,Activa)
		select @Nombre,@Activa

		set @IDCaseta = @@IDENTITY

		if (@TotalLockers > 0)
		begin
			;WITH cteLockers(Codigo) AS
			(
				SELECT 1
				UNION ALL
				SELECT Codigo+1 FROM cteLockers WHERE Codigo < @TotalLockers
			)

			insert [Resguardo].[tblCatLockers](IDCaseta,Codigo)
			SELECT @IDCaseta as IDCaseta,cast(Codigo as varchar(50))
			FROM cteLockers 
			ORDER BY Codigo
			OPTION (MAXRECURSION 1000);
		end;
	end else
	begin
		update [Resguardo].[tblCatCasetas]
			set Nombre = @Nombre,
				Activa = @Activa
		where IDCaseta = @IDCaseta
	end;
GO
