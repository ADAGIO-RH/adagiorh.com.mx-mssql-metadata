USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spAplicarHistorialesAEmpleado](
	@IDPosicion int,
	@IDEmpleado int,
	@SueldoAsignado Decimal(18,4) = 0,
	@FechaAplicacion Date,
    @dtHistorial_a_Modificar [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDPlaza int,
		@IDPuesto int,
		@ConfiguracionJson varchar(max),
        @IDCliente int ,
		@IDJefe int,
		@IDRegPatronalPrevio int,
		@ID_TIPO_MOVIMIENTO_BAJA int = 2,
		@ID_TIPO_MOVIMIENTO_REINGRESO int = 3,
		@ID_TIPO_MOVIMIENTO_MOVIMIENTO_SALARIAL int = 4
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

    Select 
		@IDPlaza = p.IDPlaza,
		@IDPuesto = pl.IDPuesto,
		@ConfiguracionJson = pl.Configuraciones,
        @IDCliente=pl.IDCliente
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
	

    DECLARE @validacionPrincipal  bit ;
    declare @validacionSecundaria bit;

    set @validacionSecundaria =  CASE 
                                    WHEN (select count(*) from @dtHistorial_a_Modificar)=0 
                                    then 0 else 1 end;
        

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='PosicionJefe');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- POSICION JEFE
    BEGIN
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'PosicionJefe')
        BEGIN
            SELECT @IDJefe = IDEmpleado 
            from RH.tblCatPosiciones WITH(NOLOCK)
            WHERE IDPosicion = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'PosicionJefe')

            IF @IDJefe != @IDEmpleado 
            BEGIN
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
            
        END
    END 
	

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Puesto');
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- PUESTO
    BEGIN 
        IF (isnull(@IDPuesto, 0) != 0)
        BEGIN
            --SET @IDPuesto = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Puesto')
            EXEC RH.spUIPuestoEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDPuesto = @IDPuesto
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario

        END
    END 


    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Departamento');
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- DEPARTAMENTO
    BEGIN  
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Departamento')
        BEGIN
            DECLARE @IDDepartamento int
            SET @IDDepartamento = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Departamento')

            if not exists(select top 1 1
                        from RH.tblCatDepartamentos
                        where IDDepartamento = @IDDepartamento)
            begin
                raiserror('El Departamento asignado a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUIDepartamentoEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDDepartamento = @IDDepartamento
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END    
    END 


    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Sucursal');
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- SUCURSAL
    BEGIN 
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Sucursal')
        BEGIN
            DECLARE @IDSucursal int
            SET @IDSucursal = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Sucursal')

            if not exists(select top 1 1
                        from RH.tblCatSucursales
                        where IDSucursal = @IDSucursal)
            begin
                raiserror('La sucursal asignada a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUISucursalEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDSucursal = @IDSucursal
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END    
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Prestaciones');
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- PRESTACION
    BEGIN  
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Prestaciones')
        BEGIN
            DECLARE @IDTipoPrestacion int
            SET @IDTipoPrestacion = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Prestaciones')

            if not exists(select top 1 1
                        from RH.tblCatTiposPrestaciones
                        where IDTipoPrestacion = @IDTipoPrestacion)
            begin
                raiserror('La prestación asignada a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUIPrestacionEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDTipoPrestacion = @IDTipoPrestacion
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END    
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='RegistroPatronal');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- REGISTROPATRONAL
    BEGIN     
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'RegistroPatronal')
        BEGIN
            DECLARE @IDRegPatronal int,
                @Vigente bit,
                @FechaAnteriorMov DATE = DATEADD(day,-1,@FechaAplicacion),
                @SalarioVariable decimal(18,2),
                @SalarioIntegrado decimal(18,2),
                @SalarioDiarioReal decimal(18,2)

            SET @IDRegPatronal = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'RegistroPatronal')
            SELECT TOP 1 
                @IDRegPatronalPrevio = IDRegPatronal ,
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
                            @IDTipoMovimiento = @ID_TIPO_MOVIMIENTO_BAJA,    
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
                            @IDTipoMovimiento = @ID_TIPO_MOVIMIENTO_REINGRESO,    
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
                            @IDTipoMovimiento = @ID_TIPO_MOVIMIENTO_MOVIMIENTO_SALARIAL,    
                            @IDRazonMovimiento  = 5,    
                            @SalarioDiario = @SueldoAsignado,    
                            @SalarioIntegrado = @SalarioIntegrado,    
                            @SalarioVariable = @SalarioVariable,    
                            @SalarioDiarioReal = @SalarioDiarioReal,    
                            @IDRegPatronal = @IDRegPatronal,
                            @RespetarAntiguedad = 1,
                            @IDUsuario = @IDUsuario ;
                END

                --EXEC RH.spUIRegPatronalEmpleado
                --	@IDEmpleado = @IDEmpleado
                --	,@IDRegPatronal = @IDRegPatronal
                --	,@FechaIni = @FechaAplicacion
                --	,@FechaFin = '9999-12-31'
                --	,@IDUsuario = @IDUsuario

            END
            ELSE
            BEGIN
                EXEC [IMSS].[spUIMovAfiliatorio]
                            @IDMovAfiliatorio = 0,
                            @Fecha = @FechaAplicacion,    
                            @IDEmpleado = @IDEmpleado,    
                            @IDTipoMovimiento = @ID_TIPO_MOVIMIENTO_REINGRESO,    
                            @IDRazonMovimiento  = 4,    
                            @SalarioDiario = @SueldoAsignado,    
                            @SalarioIntegrado = @SalarioIntegrado,    
                            @SalarioVariable = 0,    
                            @SalarioDiarioReal = @SalarioDiarioReal,    
                            @IDRegPatronal = @IDRegPatronal,
                            @RespetarAntiguedad = 0,
                            @IDUsuario = @IDUsuario ;

                --EXEC RH.spUIRegPatronalEmpleado
                -- @IDEmpleado = @IDEmpleado
                --,@IDRegPatronal = @IDRegPatronal
                --,@FechaIni = @FechaAplicacion
                --,@FechaFin = '9999-12-31'
                --,@IDUsuario = @IDUsuario
            END

        
        END
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Empresa');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- EMPRESA
    BEGIN     
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Empresa')
        BEGIN
            DECLARE @IDRazonSocial int
            SET @IDRazonSocial = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Empresa')

            if not exists(select top 1 1
                        from RH.tblEmpresa
                        where IDEmpresa = @IDRazonSocial)
            begin
                raiserror('La Razón social asignada a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUIEmpresaEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDEmpresa = @IDRazonSocial
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='CentroCosto');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- CENTRO COSTO
    BEGIN 
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'CentroCosto')
        BEGIN
            DECLARE @IDCentroCosto int
            SET @IDCentroCosto = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'CentroCosto')

            if not exists(select top 1 1
                        from RH.tblCatCentroCosto
                        where IDCentroCosto = @IDCentroCosto)
            begin
                raiserror('El centro de costo asignado a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUICentroCostoEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDCentroCosto = @IDCentroCosto
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END    
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Area');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- AREA
    BEGIN 
        select 'area'


        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Area')
        BEGIN
            DECLARE @IDArea int
            SET @IDArea = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Area')

            if not exists(select top 1 1
                        from RH.tblCatArea
                        where IDArea = @IDArea)
            begin
                raiserror('El área asignada a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUIAreaEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDArea = @IDArea
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END    
    END 
    

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Division');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- DIVISION
    BEGIN 
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Division')
        BEGIN
            DECLARE @IDDivision int
            SET @IDDivision = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Division')

            if not exists(select top 1 1
                        from RH.tblCatDivisiones
                        where IDDivision = @IDDivision)
            begin
                raiserror('La división asignada a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUIDivisionEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDDivision = @IDDivision
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END    
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Region');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- REGION
    BEGIN     
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Region')
        BEGIN
            DECLARE @IDRegion int
            SET @IDRegion = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Region')

            if not exists(select top 1 1
                        from RH.tblCatRegiones
                        where IDRegion = @IDRegion)
            begin
                raiserror('La región asignada a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUIRegionEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDRegion = @IDRegion
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='ClasificacionCorporativa');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- CLASIFICACIONCORPORATIVA
    BEGIN 
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'ClasificacionCorporativa')
        BEGIN
            DECLARE @IDClasificacionCorporativa int
            SET @IDClasificacionCorporativa = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'ClasificacionCorporativa')

            if not exists(select top 1 1
                        from RH.tblCatClasificacionesCorporativas
                        where IDClasificacionCorporativa = @IDClasificacionCorporativa)
            begin
                raiserror('La clasificación corporativa asignada a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            EXEC RH.spUIClasificacionCorporativaEmpleado
                @IDEmpleado = @IDEmpleado
                ,@IDClasificacionCorporativa = @IDClasificacionCorporativa
                ,@FechaIni = @FechaAplicacion
                ,@FechaFin = '9999-12-31'
                ,@IDUsuario = @IDUsuario
        END    
    END 


    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Perfil');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- PERFIL
    BEGIN 
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Perfil')
        BEGIN
            DECLARE @IDPerfil int
            SET @IDPerfil = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'Perfil')

            if not exists(select top 1 1
                        from Seguridad.tblCatPerfiles
                        where IDPerfil = @IDPerfil)
            begin
                raiserror('El perfil asignado a la plaza no existe en el catálogo.', 16, 1)
                return
            end

            UPDATE Seguridad.tblUsuarios set IDPerfil = @IDPerfil where IDEmpleado=@IDEmpleado                  
        END    
    END 


    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='Cliente');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- CLIENTE
    BEGIN     
        IF (@IDCliente IS NOT NULL )
        BEGIN			
            if not exists(select top 1 1
                        from RH.tblCatClientes
                        where IDCliente = @IDCliente)
            begin
                raiserror('El cliente asignado a la plaza no existe en el catálogo.', 16, 1)
                return
            end
            exec [RH].[spUIClienteEmpleado]            
                @IDEmpleado =@IDEmpleado    
                ,@IDCliente =@IDCliente
                ,@FechaIni = @FechaAplicacion    
                ,@FechaFin ='9999-12-31'  
                ,@IDUsuario = @IDUsuario                
        END
    END 

    set @validacionPrincipal= (select [Value] from  @dtHistorial_a_Modificar  where Catalogo='TipoNomina');    
    IF( @validacionPrincipal =1 AND @validacionSecundaria=1) -- TIPO NOMINA
    BEGIN 
        IF EXISTS( SELECT TOP 1 1 FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'TipoNomina')
        BEGIN
            DECLARE @IDTipoNomina int
            SET @IDTipoNomina = (SELECT TOP 1 Valor FROM @tblConfiguracion WHERE IDTipoConfiguracionPlaza = 'TipoNomina')

            if not exists(select top 1 1
                        from  Nomina.tblCatTipoNomina 
                        where IDTipoNomina = @IDTipoNomina)
            begin
                raiserror('El tipo de nómina asignado a la plaza no existe en el catálogo.', 16, 1)
                return
            end
            exec [RH].[spUITipoNominaEmpleado]            
                @IDEmpleado =@IDEmpleado    
                ,@IDTipoNomina =@IDTipoNomina
                ,@FechaIni = @FechaAplicacion    
                ,@FechaFin ='9999-12-31'  
                ,@IDUsuario = @IDUsuario                
        END    
    END 
    
    exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado
 

END
GO
