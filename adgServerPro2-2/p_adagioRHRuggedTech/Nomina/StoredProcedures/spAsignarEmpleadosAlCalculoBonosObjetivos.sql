USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spAsignarEmpleadosAlCalculoBonosObjetivos]
    @IDControlBonosObjetivos INT,
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @FechaReferencia DATE,
        @IDTipoNomina INT,
        @FechaInformacionColaboradores DATE,
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spAsignarEmpleadosAlCalculoBonosObjetivos]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivosDetalle]',
        @Accion VARCHAR(20) = 'INSERT',
        @FiltrosAsignacionEmpleados NVARCHAR(MAX),        
        @Empleados [RH].[dtEmpleados];

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT             
            @FechaReferencia = FechaReferencia,
            @IDTipoNomina = IDTipoNomina,
            @FechaInformacionColaboradores = FechaInformacionColaboradores
        FROM [Nomina].[tblControlBonosObjetivos]
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;
        
        
            
        
        INSERT INTO @Empleados
        EXEC RH.spBuscarEmpleados 
            @IDTipoNomina = @IDTipoNomina,
            @FechaIni = @FechaInformacionColaboradores,            
            @Fechafin = @FechaInformacionColaboradores,
            @dtFiltros = @dtFiltros,
            @IDUsuario = @IDUsuario;

        IF OBJECT_ID('tempdb..#tempEmpleadosTrabajables') IS NOT NULL DROP TABLE #tempEmpleadosTrabajables;

        SELECT 
                e.IDEmpleado,
                CASE WHEN e.IDPuesto = 0 THEN NULL ELSE e.IDPuesto END AS IDPuesto,
                CASE WHEN e.IDRegPatronal = 0 THEN NULL ELSE e.IDRegPatronal END AS IDRegPatronal,
                CASE WHEN e.IDDivision = 0 THEN NULL ELSE e.IDDivision END AS IDDivision,
                CASE WHEN e.IDRegion = 0 THEN NULL ELSE e.IDRegion END AS IDRegion,
                CASE WHEN e.IDArea = 0 THEN NULL ELSE e.IDArea END AS IDArea,
                CASE WHEN e.IDSucursal = 0 THEN NULL ELSE e.IDSucursal END AS IDSucursal,
                CASE WHEN e.IDCliente = 0 THEN NULL ELSE e.IDCliente END AS IDCliente,
                CASE WHEN e.IDEmpresa = 0 THEN NULL ELSE e.IDEmpresa END AS IDEmpresa,
                CASE WHEN e.IDCentroCosto = 0 THEN NULL ELSE e.IDCentroCosto END AS IDCentroCosto,
                CASE WHEN e.IDTipoPrestacion = 0 THEN NULL ELSE e.IDTipoPrestacion END AS IDTipoPrestacion,
                CASE WHEN e.IDDepartamento = 0 THEN NULL ELSE e.IDDepartamento END AS IDDepartamento,
                ISNULL(cp.NivelSalarialCompensaciones,0) AS NivelSalarialCompensaciones,
                e.FechaAntiguedad,
                tpd.Factor,
            ISNULL(FLOOR(DATEDIFF(day,E.FechaAntiguedad,@FechaInformacionColaboradores)/365.0)+1,0) AS Antiguedad
        INTO #tempEmpleadosTrabajables
        FROM @Empleados e
        LEFT JOIN RH.tblCatPuestos cp ON e.IDPuesto = cp.IDPuesto
        LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK)
            ON TPD.IDTipoPrestacion = E.IDTipoPrestacion
            AND (tpd.Antiguedad = FLOOR(DATEDIFF(day,E.FechaAntiguedad,@FechaInformacionColaboradores)/365.0)+1)
        --WHERE DATEDIFF(DAY, e.FechaAntiguedad, @FechaReferencia) >= @DiasMinimosLaborados

        

        MERGE [Nomina].[tblControlBonosObjetivosDetalle] AS TARGET
        USING #tempEmpleadosTrabajables AS SOURCE
        ON TARGET.IDEmpleado = SOURCE.IDEmpleado AND TARGET.IDControlBonosObjetivos = @IDControlBonosObjetivos
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.IDPuesto = SOURCE.IDPuesto,
                TARGET.IDRegPatronal = SOURCE.IDRegPatronal,
                TARGET.IDDivision = SOURCE.IDDivision,
                TARGET.IDRegion = SOURCE.IDRegion,
                TARGET.IDArea = SOURCE.IDArea,
                TARGET.IDSucursal = SOURCE.IDSucursal,
                TARGET.IDDepartamento = SOURCE.IDDepartamento,
                TARGET.IDCliente = SOURCE.IDCliente,
                TARGET.IDEmpresa = SOURCE.IDEmpresa,
                TARGET.IDCentroCosto = SOURCE.IDCentroCosto,
                TARGET.FechaAntiguedad = SOURCE.FechaAntiguedad,
                TARGET.IDTipoPrestacion = SOURCE.IDTipoPrestacion,
                TARGET.Antiguedad = SOURCE.Antiguedad,
                TARGET.NivelSalarial = SOURCE.NivelSalarialCompensaciones,
                TARGET.Factor = SOURCE.Factor
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (IDControlBonosObjetivos, IDEmpleado, IDPuesto, IDRegPatronal, IDDivision, IDRegion, IDArea, IDSucursal, IDCliente, IDEmpresa, IDCentroCosto, IDDepartamento, FechaAntiguedad, IDTipoPrestacion, Antiguedad, Factor, NivelSalarial)
            VALUES (@IDControlBonosObjetivos, SOURCE.IDEmpleado, SOURCE.IDPuesto, SOURCE.IDRegPatronal, SOURCE.IDDivision, SOURCE.IDRegion, SOURCE.IDArea, SOURCE.IDSucursal, SOURCE.IDCliente, SOURCE.IDEmpresa, SOURCE.IDCentroCosto, SOURCE.IDDepartamento, SOURCE.FechaAntiguedad, SOURCE.IDTipoPrestacion, SOURCE.Antiguedad, SOURCE.Factor, SOURCE.NivelSalarialCompensaciones)
        WHEN NOT MATCHED BY SOURCE AND TARGET.IDControlBonosObjetivos = @IDControlBonosObjetivos THEN
            DELETE;

        SELECT @FiltrosAsignacionEmpleados = (
            SELECT * FROM @dtFiltros FOR JSON AUTO
        );

        UPDATE Nomina.tblControlBonosObjetivos
        SET FiltrosAsignacionEmpleados = @FiltrosAsignacionEmpleados
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

        SELECT @NewJSON = a.JSON
                FROM [Nomina].[tblControlBonosObjetivos] b
                CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDControlBonosObjetivos,b.Descripcion,b.Ejercicio,b.Aplicado FOR XML RAW))) a
                WHERE b.IDControlBonosObjetivos = @IDControlBonosObjetivos;


        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario = @IDUsuario,
            @Tabla = @Tabla,
            @Procedimiento = @NombreSP,
            @Accion = @Accion,
            @NewData = @NewJSON,
            @OldData = @OldJSON;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;

    SET NOCOUNT OFF;
END
GO
