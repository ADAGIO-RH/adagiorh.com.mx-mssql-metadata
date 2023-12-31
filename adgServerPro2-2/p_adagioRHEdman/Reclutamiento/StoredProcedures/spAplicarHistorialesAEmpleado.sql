USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/* 
	exec Reclutamiento.spAplicarHistorialesAEmpleado 
		@IDPosicion = 61, 
		@IDEmpleado = 390, 
		@SueldoAsignado = 15000, 
		@FechaAplicacion = '2022-05-06',  
		@IDUsuario = 1
*/
CREATE PROCEDURE [Reclutamiento].[spAplicarHistorialesAEmpleado](
	@IDPosicion int,
	@IDEmpleado int,
	@SueldoAsignado Decimal(18,4) = 0,
	@FechaAplicacion Date,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDPlaza int,
		@ConfiguracionJson varchar(max),
		@IDJefe int,
		@IDRegPatronalPrevio int
		;

	DECLARE @tblConfiguracion as Table(
	   IDTipoConfiguracionPlaza varchar(100),
	   Valor int,
	   Descripcion varchar(100)
	);

	IF(isnull(@SueldoAsignado,0) = 0)
	BEGIN
		SET @SueldoAsignado = (Select top 1 SalarioDiario from RH.tblEmpleadosMaster with(nolock) WHERE IDEmpleado = @IDEmpleado) 
	END

    Select @IDPlaza = p.IDPlaza,
		@ConfiguracionJson = pl.Configuraciones
	from RH.tblCatPosiciones P with(nolock)
		Inner join RH.tblCatPlazas pl with(nolock)
			on p.IDPlaza = pl.IDPlaza
	WHERE p.IDPosicion = @IDPosicion

	insert into @tblConfiguracion(IDTipoConfiguracionPlaza,Valor, Descripcion)
	SELECT i.IDTipoConfiguracionPlaza, i.[Valor], i.[Descripcion]
	FROM OPENJSON(@ConfiguracionJson) WITH (
	   IDTipoConfiguracionPlaza varchar(100) '$.IDTipoConfiguracionPlaza',
	   Valor int '$.Valor',
	   Descripcion varchar(100) '$.Descripcion'
	) AS i
	
	Delete c
	from @tblConfiguracion c
	WHERE isnull(c.Valor,0)= 0

	

	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'PosicionJefe')
	BEGIN
		SELECT @IDJefe = IDEmpleado 
		from RH.tblCatPosiciones WITH(NOLOCK)
		WHERE IDPosicion = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'PosicionJefe')



		IF EXISTS(SELECT TOP 1 1 FROM RH.tblJefesEmpleados WHERE IDEmpleado = @IDEmpleado )
		BEGIN
			DELETE RH.tblJefesEmpleados
			WHERE IDEmpleado = @IDEmpleado
		END

        IF @IDJefe is not null 
        BEGIN
            INSERT INTO RH.tblJefesEmpleados(IDEmpleado, IDJefe, FechaReg)
		    VALUES(@IDEmpleado,@IDJefe,getdate())
        END


	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Puesto')
	BEGIN
		DECLARE @IDPuesto int
		SET @IDPuesto = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Puesto')
		EXEC RH.spUIPuestoEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDPuesto = @IDPuesto
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario

	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Departamento')
	BEGIN
		DECLARE @IDDepartamento int
		SET @IDDepartamento = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Departamento')
		EXEC RH.spUIDepartamentoEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDDepartamento = @IDDepartamento
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Sucursal')
	BEGIN
		DECLARE @IDSucursal int
		SET @IDSucursal = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Sucursal')
		EXEC RH.spUISucursalEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDSucursal = @IDSucursal
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Prestaciones')
	BEGIN
		DECLARE @IDTipoPrestacion int
		SET @IDTipoPrestacion = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Prestaciones')
		EXEC RH.spUIPrestacionEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDTipoPrestacion = @IDTipoPrestacion
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'RegistroPatronal')
	BEGIN
		DECLARE @IDRegPatronal int,
			@Vigente bit,
			@FechaAnteriorMov DATE = DATEADD(day,-1,@FechaAplicacion),
			@SalarioVariable decimal(18,2),
			@SalarioIntegrado decimal(18,2),
			@SalarioDiarioReal decimal(18,2)

		SET @IDRegPatronal = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'RegistroPatronal')
		SELECT TOP 1 @IDRegPatronalPrevio = IDRegPatronal ,
				@Vigente = isnull(Vigente,0),
				@SalarioVariable = SalarioVariable,
				@SalarioIntegrado = SalarioIntegrado,
				@SalarioDiarioReal = SalarioDiarioReal
		FROM RH.tblEmpleadosMaster with(nolock) 
		WHERE IDEmpleado = @IDEmpleado

		IF(@Vigente = 1)
		BEGIN
			IF(@IDRegPatronal <> @IDRegPatronalPrevio)
			BEGIN
				EXEC [IMSS].[spUIMovAfiliatorio]
						@IDMovAfiliatorio = 0,
						@Fecha = @FechaAnteriorMov,    
						@IDEmpleado = @IDEmpleado,    
						@IDTipoMovimiento = 2,    
						@IDRazonMovimiento  = 2,    
						@SalarioDiario = 0,    
						@SalarioIntegrado = 0,    
						@SalarioVariable = 0,    
						@SalarioDiarioReal = 0,    
						@IDRegPatronal = @IDRegPatronalPrevio,
						@RespetarAntiguedad = 1,
						@IDUsuario = @IDUsuario ;

				EXEC [IMSS].[spUIMovAfiliatorio]
						@IDMovAfiliatorio = 0,
						@Fecha = @FechaAplicacion,    
						@IDEmpleado = @IDEmpleado,    
						@IDTipoMovimiento = 3,    
						@IDRazonMovimiento  = 4,    
						@SalarioDiario = @SueldoAsignado,    
						@SalarioIntegrado = @SalarioIntegrado,    
						@SalarioVariable = @SalarioVariable,    
						@SalarioDiarioReal = @SalarioDiarioReal,    
						@IDRegPatronal = @IDRegPatronal,
						@RespetarAntiguedad = 1,
						@IDUsuario = @IDUsuario ;
						
			END
			ELSE
			BEGIN
				EXEC [IMSS].[spUIMovAfiliatorio]
						@IDMovAfiliatorio = 0,
						@Fecha = @FechaAplicacion,    
						@IDEmpleado = @IDEmpleado,    
						@IDTipoMovimiento = 4,    
						@IDRazonMovimiento  = 5,    
						@SalarioDiario = @SueldoAsignado,    
						@SalarioIntegrado = @SalarioIntegrado,    
						@SalarioVariable = @SalarioVariable,    
						@SalarioDiarioReal = @SalarioDiarioReal,    
						@IDRegPatronal = @IDRegPatronal,
						@RespetarAntiguedad = 1,
						@IDUsuario = @IDUsuario ;
			END

			EXEC RH.spUIRegPatronalEmpleado
				@IDEmpleado = @IDEmpleado
				,@IDRegPatronal = @IDRegPatronal
				,@FechaIni = @FechaAplicacion
				,@FechaFin = '9999-12-31'
				,@IDUsuario = @IDUsuario

		END
		ELSE
		BEGIN
			EXEC [IMSS].[spUIMovAfiliatorio]
						@IDMovAfiliatorio = 0,
						@Fecha = @FechaAplicacion,    
						@IDEmpleado = @IDEmpleado,    
						@IDTipoMovimiento = 3,    
						@IDRazonMovimiento  = 4,    
						@SalarioDiario = @SueldoAsignado,    
						@SalarioIntegrado = @SalarioIntegrado,    
						@SalarioVariable = 0,    
						@SalarioDiarioReal = @SalarioDiarioReal,    
						@IDRegPatronal = @IDRegPatronal,
						@RespetarAntiguedad = 0,
						@IDUsuario = @IDUsuario ;

			EXEC RH.spUIRegPatronalEmpleado
			 @IDEmpleado = @IDEmpleado
			,@IDRegPatronal = @IDRegPatronal
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
		END

	
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'RazonSocial')
	BEGIN
		DECLARE @IDRazonSocial int
		SET @IDRazonSocial = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'RazonSocial')
		EXEC RH.spUIEmpresaEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDEmpresa = @IDRazonSocial
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'CentroCosto')
	BEGIN
		DECLARE @IDCentroCosto int
		SET @IDCentroCosto = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'CentroCosto')
		EXEC RH.spUICentroCostoEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDCentroCosto = @IDCentroCosto
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Area')
	BEGIN
		DECLARE @IDArea int
		SET @IDArea = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Area')
		EXEC RH.spUIAreaEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDArea = @IDArea
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Division')
	BEGIN
		DECLARE @IDDivision int
		SET @IDDivision = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Division')
		EXEC RH.spUIDivisionEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDDivision = @IDDivision
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Region')
	BEGIN
		DECLARE @IDRegion int
		SET @IDRegion = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Region')
		EXEC RH.spUIRegionEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDRegion = @IDRegion
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
	IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'ClasificacionCorporativa')
	BEGIN
		DECLARE @IDClasificacionCorporativa int
		SET @IDClasificacionCorporativa = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'ClasificacionCorporativa')
		EXEC RH.spUIClasificacionCorporativaEmpleado
			@IDEmpleado = @IDEmpleado
			,@IDClasificacionCorporativa = @IDClasificacionCorporativa
			,@FechaIni = @FechaAplicacion
			,@FechaFin = '9999-12-31'
			,@IDUsuario = @IDUsuario
	END
END
GO
