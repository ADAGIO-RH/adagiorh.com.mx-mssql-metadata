USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción     : Asigna empleados al cálculo de aumento de desempeño
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : '2025-01-09
** Parámetros      : 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [Nomina].[spAsignarEmpleadosAlCalculoAumentoDesempeno]
    @IDControlAumentosDesempeno INT,
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE         
        @FechaReferencia DATE,
        @FechaMovAfiliatorio DATE,
        @FechaInformacionColaboradores DATE ,
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spAsignarEmpleadosAlCalculoAumentoDesempeno]',
        @Tabla VARCHAR(MAX) = '[Nomina].[TblControlAumentosDesempenoDetalle]',
        @Accion VARCHAR(20) = 'INSERT',

        @FiltrosAsignacionEmpleados  NVARCHAR(MAX),
        @Empleados [RH].[dtEmpleados]; -- Declaración de la variable de tipo tabla        

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Obtener el valor de DiasCriterioAntiguedad y FechaReferencia
        SELECT             
            @FechaReferencia = FechaReferencia,
            @FechaMovAfiliatorio = FechaMovAfiliatorio,
            @FechaInformacionColaboradores = FechaInformacionColaboradores
        FROM [Nomina].[tblControlAumentosDesempeno]
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

                
        -- Ejecutar spBuscarEmpleados y almacenar resultados en @Empleados
        INSERT INTO @Empleados
        EXEC RH.spBuscarEmpleados 
            @FechaIni = @FechaInformacionColaboradores, 
            @Fechafin = @FechaInformacionColaboradores,
            @dtFiltros = @dtFiltros,
            @IDUsuario = @IDUsuario;

        -- Crear tabla temporal para empleados trabajables
        IF OBJECT_ID('tempdb..#tempEmpleadosTrabajables') IS NOT NULL DROP TABLE #tempEmpleadosTrabajables;

        SELECT 
                e.IDEmpleado,
                CASE WHEN e.IDPuesto = 0 THEN NULL ELSE e.IDPuesto END AS IDPuesto,
                CASE WHEN e.IDRegPatronal = 0 THEN NULL ELSE e.IDRegPatronal END AS IDRegPatronal,
                CASE WHEN e.IDDivision = 0 THEN NULL ELSE e.IDDivision END AS IDDivision,
                CASE WHEN e.IDRegion = 0 THEN NULL ELSE e.IDRegion END AS IDRegion,
                CASE WHEN e.IDArea = 0 THEN NULL ELSE e.IDArea END AS IDArea,
                CASE WHEN e.IDSucursal = 0 THEN NULL ELSE e.IDSucursal END AS IDSucursal,
                CASE WHEN e.IDDepartamento = 0 THEN NULL ELSE e.IDDepartamento END AS IDDepartamento,
                CASE WHEN e.IDCliente = 0 THEN NULL ELSE e.IDCliente END AS IDCliente,
                CASE WHEN e.IDEmpresa = 0 THEN NULL ELSE e.IDEmpresa END AS IDEmpresa,
                CASE WHEN e.IDCentroCosto = 0 THEN NULL ELSE e.IDCentroCosto END AS IDCentroCosto,
                CASE WHEN e.IDTipoPrestacion = 0 THEN NULL ELSE e.IDTipoPrestacion END AS IDTipoPrestacion,
                ISNULL(cp.NivelSalarialCompensaciones,0) AS NivelSalarialCompensaciones,
                e.FechaAntiguedad,
                tpd.Factor,
                ISNULL(FLOOR(DATEDIFF(day,E.FechaAntiguedad,@FechaMovAfiliatorio)/365.0)+1,0) AS Antiguedad                


        INTO #tempEmpleadosTrabajables
        FROM @Empleados e
        LEFT JOIN RH.tblCatPuestos cp ON e.IDPuesto = cp.IDPuesto
        LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD WITH(NOLOCK)
               ON  TPD.IDTipoPrestacion = E.IDTipoPrestacion            
              AND (tpd.Antiguedad = FLOOR(DATEDIFF(day,E.FechaAntiguedad,@FechaMovAfiliatorio)/365.0)+1)   
        --WHERE DATEDIFF(DAY, e.FechaAntiguedad, @FechaReferencia) >= @DiasCriterioAntiguedad;
        --- ESTA VALIDACIÓN SE PASARÁ A OTRO APARTADO




        -- Usar MERGE para insertar empleados que cumplan con el criterio de antigüedad
        MERGE [Nomina].[TblControlAumentosDesempenoDetalle] AS TARGET
        USING #tempEmpleadosTrabajables AS SOURCE
        ON TARGET.IDEmpleado = SOURCE.IDEmpleado AND TARGET.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.IDPuesto = SOURCE.IDPuesto,
                TARGET.IDRegPatronal = SOURCE.IDRegPatronal,
                TARGET.IDDivision = SOURCE.IDDivision,
                TARGET.IDRegion = SOURCE.IDRegion,
                TARGET.IDArea = SOURCE.IDArea,
                TARGET.IDSucursal = SOURCE.IDSucursal,
                TARGET.IDCliente = SOURCE.IDCliente,
                TARGET.IDEmpresa = SOURCE.IDEmpresa,
                TARGET.IDCentroCosto = SOURCE.IDCentroCosto,
                TARGET.IDDepartamento = SOURCE.IDDepartamento,
                TARGET.NivelSalarial = SOURCE.NivelSalarialCompensaciones,
                TARGET.FechaAntiguedad = SOURCE.FechaAntiguedad,
                TARGET.IDTipoPrestacion = SOURCE.IDTipoPrestacion,
                TARGET.Antiguedad = SOURCE.Antiguedad,
                TARGET.Factor = SOURCE.Factor                
        WHEN NOT MATCHED BY TARGET THEN



        INSERT (IDControlAumentosDesempeno, IDEmpleado, IDPuesto, IDRegPatronal, IDDivision, IDRegion, IDArea, IDSucursal, IDCliente, IDEmpresa, IDCentroCosto, IDDepartamento, NivelSalarial, FechaAntiguedad, IDTipoPrestacion, Antiguedad, Factor)
        VALUES (@IDControlAumentosDesempeno, SOURCE.IDEmpleado, SOURCE.IDPuesto, SOURCE.IDRegPatronal, SOURCE.IDDivision, SOURCE.IDRegion, SOURCE.IDArea, SOURCE.IDSucursal, SOURCE.IDCliente, SOURCE.IDEmpresa, SOURCE.IDCentroCosto, SOURCE.IDDepartamento, SOURCE.NivelSalarialCompensaciones, SOURCE.FechaAntiguedad, SOURCE.IDTipoPrestacion, SOURCE.Antiguedad, SOURCE.Factor)       


        WHEN NOT MATCHED BY SOURCE AND TARGET.IDControlAumentosDesempeno = @IDControlAumentosDesempeno AND TARGET.IDEmpleado NOT IN (SELECT IDEmpleado FROM #tempEmpleadosTrabajables)
        THEN
            DELETE;


        SELECT @FiltrosAsignacionEmpleados = (
            SELECT *        
            FROM 
            @dtFiltros
            FOR JSON AUTO
        );

        UPDATE Nomina.tblControlAumentosDesempeno
        SET FiltrosAsignacionEmpleados = @FiltrosAsignacionEmpleados
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno

        -- Obtener el nuevo estado para auditoría
        SELECT @NewJSON = a.JSON
        FROM [Nomina].[tblControlAumentosDesempeno] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDControlAumentosDesempeno,b.Descripcion,b.Ejercicio,b.Aplicado FOR XML RAW))) a
        WHERE b.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

        -- Registrar auditoría
        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario      = @IDUsuario,
            @Tabla          = @Tabla,
            @Procedimiento  = @NombreSP,
            @Accion         = @Accion,
            @NewData        = @NewJSON,
            @OldData        = @OldJSON;

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
