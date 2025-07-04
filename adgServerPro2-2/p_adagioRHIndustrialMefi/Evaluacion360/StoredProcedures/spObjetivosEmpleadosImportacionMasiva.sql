USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: SP importación objetivos empleados
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2024-01-31
** Paremetros		:               

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE   PROCEDURE [Evaluacion360].[spObjetivosEmpleadosImportacionMasiva] 	
    @NombreObjetivo varchar(500),
	@DescripcionObjetivo varchar(max),
	@IDCicloMedicionObjetivo int,
    @IDTipoMedicionObjetivo int,
    @IDEmpleado int,
    @Objetivo varchar(max),	
	@Peso decimal(18,2),
	@IDEstatusObjetivoEmpleado int,
    @IDPeriodicidadActualizacion int,
    @IDOperador int,
    @ValorActual varchar(max),
	@IDUsuario int		
AS
BEGIN
            DECLARE @IDObjetivoEmpleado INT = 0
                   ,@FechaHoy DATE= GETDATE();
            

            IF OBJECT_ID('tempdb..#TempResultNuevoObjetivo') IS NOT NULL DROP TABLE #TempResultNuevoObjetivo; 
            
            CREATE TABLE #TempResultNuevoObjetivo (
                        IDObjetivoEmpleado INT,
                        Nombre NVARCHAR(MAX),
                        Descripcion NVARCHAR(MAX),
                        IDTipoMedicionObjetivo INT,
                        TipoMedicionObjetivo NVARCHAR(MAX),
                        IDEmpleado INT,
                        IDCicloMedicionObjetivo INT,
                        CicloMedicionObjetivo NVARCHAR(MAX),
                        Colaborador NVARCHAR(MAX),
                        Objetivo NVARCHAR(MAX),
                        Actual NVARCHAR(MAX),
                        Peso DECIMAL(18, 2),
                        PorcentajeAlcanzado DECIMAL(18, 2),
                        IDEstatusObjetivoEmpleado INT,
                        IDEstatusAutorizacion INT,
                        EstatusAutorizacion NVARCHAR(MAX),
                        EstatusObjetivoEmpleado NVARCHAR(MAX),
                        IDOperador INT,
                        Operador NVARCHAR(MAX),
                        IDPeriodicidadActualizacion INT,
                        PeriodicidadActualizacion NVARCHAR(MAX),
                        IDUsuarioCreo INT,
                        UsuarioCreo NVARCHAR(MAX),
                        IDUsuarioAutorizo INT,
                        UsuarioAutorizo NVARCHAR(MAX),
                        FechaHoraReg DATETIME,
                        PorcentajeAlcanzadoPlanAccionObjetivo DECIMAL(18, 2),
                        PlanAccionObjetivo INT,
                        AvancesObjetivoEmpleado INT,
                        EsJefeUsuarioConsulta BIT,
                        ObjetivoPerteneceAConsultante BIT,
                        ObjetivoCapturadoPorConsultante BIT,
                        ObjetivoCapturadoPorEmpleado BIT,
                        TotalPaginas INT,  
                        TotalRegistros INT  
            );

              INSERT INTO #TempResultNuevoObjetivo
                EXEC [Evaluacion360].[spIUObjetivoEmpleado]
                            @Nombre = @NombreObjetivo,
                            @Descripcion = @DescripcionObjetivo,
                            @IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo,
                            @IDTipoMedicionObjetivo = @IDTipoMedicionObjetivo,
                            @IDEmpleado = @IDEmpleado,
                            @Objetivo = @Objetivo, 
                            @Peso = @Peso,
                            @IDEstatusObjetivoEmpleado = @IDEstatusObjetivoEmpleado,
                            @IDPeriodicidadActualizacion = @IDPeriodicidadActualizacion,
                            @IDOperador = @IDOperador,
                            @IDUsuarioCreo = @IDUsuario;

                
                IF(@ValorActual IS NOT NULL)
                BEGIN
                    
                    SELECT TOP 1 @IDObjetivoEmpleado=IDObjetivoEmpleado
                    FROM #TempResultNuevoObjetivo

                    EXEC [Evaluacion360].[spIAvanceObjetivoEmpleado]	                         
                             @IDObjetivoEmpleado=@IDObjetivoEmpleado	
                            ,@Valor=@ValorActual
                            ,@Fecha= @FechaHoy
                            ,@Comentario ='SE REALIZA POR MEDIO DE IMPORTACIÓN DE OBJETIVOS EMPLEADOS MASIVA'
	                        ,@IDUsuario = @IDUsuario
                    
                END
  

END
GO
