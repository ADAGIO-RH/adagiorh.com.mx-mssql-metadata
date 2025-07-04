USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spIUEncuesta](
	@IDEncuesta int = 0
	,@IDCatEncuesta int 
	,@NombreEncuesta Varchar(255)
	,@FechaIni date
	,@FechaFin date
	,@IDEmpresa int = 0
	,@IDSucursal int = 0
	,@IDCliente int = 0
	,@CantidadEmpleados int = 0
	,@EsAnonimo bit = 0
	,@IDCatEstatus int
	,@IDUsuario int
)
AS
BEGIN
	set @NombreEncuesta = UPPER(@NombreEncuesta)

	IF(isnull(@IDEncuesta,0) = 0)
	BEGIN
		Insert into Norma35.tblEncuestas(IDCatEncuesta,NombreEncuesta,FechaIni,FechaFin,IDEmpresa,IDSucursal,IDCliente,CantidadEmpleados,EsAnonimo,FechaCreacion, IDCatEstatus,IDUsuario)
		Values (@IDCatEncuesta
				,@NombreEncuesta
				,@FechaIni
				,@FechaFin
				,CASE WHEN ISNULL(@IDEmpresa,0) = 0 THEN NULL ELSE @IDEmpresa END
				,CASE WHEN ISNULL(@IDSucursal,0) = 0 THEN NULL ELSE @IDSucursal END
				,CASE WHEN ISNULL(@IDCliente,0) = 0 THEN NULL ELSE @IDCliente END
				,@CantidadEmpleados
				,@EsAnonimo
				,getdate()
				,@IDCatEstatus
				,@IDUsuario)	

		set @IDEncuesta = SCOPE_IDENTITY()

		EXEC Norma35.spCrearListaEmpleadosEncuestaRandom @IDEncuesta= @IDEncuesta, @IDEmpresa= @IDEmpresa, @IDSucursal= @IDSucursal,@IDCliente= @IDCliente,@CantidadEmpleados = @CantidadEmpleados, @IDUsuario= @IDUsuario

	END
	ELSE
	BEGIN
		UPDATE Norma35.tblEncuestas
			set IDCatEncuesta = @IDCatEncuesta
			,NombreEncuesta = @NombreEncuesta
			,FechaIni = @FechaIni
			,FechaFin = @FechaFin
			,IDEmpresa = CASE WHEN ISNULL(@IDEmpresa,0) = 0 THEN NULL ELSE @IDEmpresa END
			,IDSucursal = CASE WHEN ISNULL(@IDSucursal,0) = 0 THEN NULL ELSE @IDSucursal END
			,IDCliente = CASE WHEN ISNULL(@IDCliente,0) = 0 THEN NULL ELSE @IDCliente END
			,CantidadEmpleados = ISNULL(@CantidadEmpleados,0)
			,EsAnonimo = ISNULL(@EsAnonimo,0)
			,IDCatEstatus = @IDCatEstatus
		WHERE IDEncuesta = @IDEncuesta
	END

	Exec Norma35.spBuscarEncuestas @IDEncuesta = @IDEncuesta, @IDUsuario = @IDUsuario
END;
GO
