USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spBorrarCatPeriodos]
(
	 @IDPeriodo int,
     @ConfirmarEliminar BIT = 0,
	 @IDUsuario int 
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarCatPeriodos]',
		@Tabla		varchar(max) = '[Nomina].[tblCatPeriodos]',
		@Accion		varchar(20)	= 'DELETE',
		@CustomMessage varchar(max),
        @Presupuesto bit, 
        @Mensaje  VARCHAR(MAX) = '',
        @tran int
	;

    BEGIN TRY  
    set @tran = @@TRANCOUNT

        select @OldJSON = a.JSON 
        ,@Presupuesto = ISNULL(b.Presupuesto,0)
        from [Nomina].[tblcatPeriodos] b with (nolock)
            Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
        WHERE  IDPeriodo = @IDPeriodo

        IF object_ID('TEMPDB..#TempBuscarPeriodos') IS NOT NULL DROP TABLE #TempBuscarPeriodos
        CREATE TABLE #TempBuscarPeriodos (
            IDPeriodo INT,
            IDTipoNomina INT,
            TipoNomina NVARCHAR(100),
            IDPeriodicidadPago INT,
            PerioricidadPago NVARCHAR(100),
            IDCliente INT,
            Cliente NVARCHAR(100),
            Ejercicio INT,
            ClavePeriodo NVARCHAR(50),
            Descripcion NVARCHAR(100),
            FechaInicioPago DATETIME,
            FechaFinPago DATETIME,
            FechaInicioIncidencia DATETIME,
            FechaFinIncidencia DATETIME,
            Dias INT,
            AnioInicio BIT,
            AnioFin BIT,
            MesInicio BIT,
            MesFin BIT,
            IDMes INT,
            Mes NVARCHAR(100),
            BimestreInicio BIT,
            BimestreFin BIT,
            General BIT,
            Finiquito BIT,
            Especial BIT,
            Cerrado BIT,
            Aguinaldo BIT,
            PTU BIT,
            DevolucionFondoAhorro BIT,
            Presupuesto BIT,
            FullDescripcion NVARCHAR(300),
            ClienteTipoNomina NVARCHAR(200),
            ROWNUMBER INT,
            TotalPaginas int,
            TotalRegistros int
        );

        Insert into #TempBuscarPeriodos
        exec Nomina.spBuscarCatPeriodos @IDPeriodo = @IDPeriodo,@Presupuesto = @Presupuesto, @IDUsuario = @IDUsuario

               
        

        IF(@ConfirmarEliminar = 0 ) 
        BEGIN
            IF EXISTS (SELECT TOP 1 1 FROM Nomina.tblDetallePeriodo WHERE IDPeriodo = @IDPeriodo)
            BEGIN
                SET @Mensaje = '<li>Existen Calculos de nomina en este periodo</li>'
            END    
        
            IF EXISTS (SELECT TOP 1 1 FROM Nomina.tblDetallePeriodoPresupuesto WHERE IDPeriodo = @IDPeriodo)
            BEGIN
                SET @Mensaje = @Mensaje + '<li>Existen calculos de nomina de presupuesto en este periodo.</li>'
            END
            IF EXISTS (SELECT TOP 1 1 FROM Nomina.tblDetallePeriodoFiniquito WHERE IDPeriodo = @IDPeriodo)
            BEGIN
                SET @Mensaje = @Mensaje + '<li>Existen calculos de finiquitos en este periodo.</li>'
            END
        

            IF(@Mensaje IS NOT NULL AND @Mensaje <> '')
            BEGIN            
                Set @Mensaje = @Mensaje + '<p>¿Deseas Borras este Periodo?</p>'        
                SELECT * , @Mensaje AS Mensaje, 1 AS TipoRespuesta from #TempBuscarPeriodos
                RETURN;            
            END
            ELSE
            BEGIN
            SET @ConfirmarEliminar = 1
            END   
        END
        
        IF(@ConfirmarEliminar = 1)
            BEGIN 
            BEGIN TRANSACTION TranBorrarPeriodo  

                Delete Nomina.tblDetallePeriodo
                where IDPeriodo = @IDPeriodo

                Delete Nomina.tblDetallePeriodoPresupuesto
                where IDPeriodo = @IDPeriodo
            
                Delete Nomina.tblDetallePeriodoFiniquito
                where IDPeriodo = @IDPeriodo

                Delete Nomina.tblHistorialesEmpleadosPeriodos
                where IDPeriodo = @IDPeriodo

                Delete Nomina.tblCatPeriodos
                where IDPeriodo = @IDPeriodo

                SELECT * , @Mensaje AS Mensaje, 0 AS TipoRespuesta from #TempBuscarPeriodos

                COMMIT TRANSACTION TranBorrarPeriodo
            END
        
        
    END TRY  
    BEGIN CATCH  

        set @tran = @@TRANCOUNT
		IF (@tran > 0) ROLLBACK TRANSACTION TranBorrarPeriodo
        
		set @CustomMessage = ERROR_MESSAGE()
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002',@CustomMessage=@CustomMessage
		return 0;
    END CATCH ;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO
