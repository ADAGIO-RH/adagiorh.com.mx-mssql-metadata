USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 
CREATE PROCEDURE [Reportes].[spPrestamosAbonosExcel]  
	-- Add the parameters for the stored procedure here
		 @dtFiltros Nomina.dtFiltrosRH readonly
         ,@IDUsuario   int  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    IF 1=0 
	BEGIN
		SET FMTONLY OFF
    END


	 
	if object_id('tempdb..#tempListEmp') is not null drop table #tempListEmp; 
	if object_id('tempdb..#tempDetallePeriodo') is not null drop table #tempDetallePeriodo;                  
                 
    CREATE table #tempDetallePeriodo (                  
		[IDPrestamo] [int] NULL,                  
		[Codigo] [varchar](25) NOT NULL,
		[IDEmpleado] [int] NOT NULL,    
		[ClaveEmpleado] [varchar](25) NOT NULL,
		[Nombre] [varchar](50) NOT NULL,
		[SegundoNombre] [varchar](50)   default '',
		[Paterno] [varchar](50) NOT NULL,
		[Materno] [varchar](50) NOT NULL,
		[NOMBRECOMPLETO] [varchar](200) NOT NULL,
		[IDTipoPrestamo] [int] NOT NULL,
		[TipoPrestamo] [varchar](100) NOT NULL,
		[IDEstatusPrestamo] [int] NOT NULL,
		[EstatusPrestamo] [varchar](20) NOT NULL,
		[MontoPrestamo] [decimal](18, 4) NOT  NULL default 0,
		[Cuotas] [decimal](18, 4)   NOT NULL default 0,       
		[CantidadCuotas] [int] NOT NULL,
		[Descripcion] [varchar](MAX) NOT NULL,
		[FechaCreacion]   [date] NOT NULL,
		[FechaInicioPago] [date] NOT NULL,
		[Balance] [decimal](18, 4)   NOT NULL default 0, 
		[Intereses] [decimal](18, 4)   NOT NULL default 0, 
		[ROWNUMBER] [int] NOT NULL,
        [TotalPaginas] [int],
        [TotalRegistros] [int]
    );    
 
		 
	 
	SELECT   ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) as [ROW ], cast(item as Varchar(20)) as IDEmpleado INTO #tempListEmp  
	FROM App.Split((Select top 1 Value from @dtFiltros  where Catalogo = 'Empleados'),',')

	
		
	DECLARE @Rows INT
	Declare @Focus INT
	SET @Focus=1
	SELECT  @Rows=COUNT(*) FROM #tempListEmp
	WHILE ( @Focus <= @Rows)
	BEGIN
	
		DECLARE @temp int;
		SELECT @temp=IDEmpleado from #tempListEmp c where c.[ROW ]=@Focus
 
		INSERT INTO #tempDetallePeriodo
		EXEC [Nomina].[spBuscarPrestamos] @IDEmpleado= @temp ,
									@IDPrestamo=0,
									@EsFonacot=0,
									@IDUsuario=@IDUsuario
		 
		 

		SET @Focus  = @Focus  + 1
	END

	select 
    [IDPrestamo],
    [Codigo],
    [IDEmpleado],
    [ClaveEmpleado],
    [Nombre],
    [SegundoNombre],
    [Paterno],
    [Materno],
    [NOMBRECOMPLETO],
    [IDTipoPrestamo],
    [TipoPrestamo],
    [IDEstatusPrestamo],
    [EstatusPrestamo],
    [MontoPrestamo],
    [Cuotas],
    [CantidadCuotas],
    [Descripcion],
    [FechaCreacion],
    [FechaInicioPago],
    [Balance],
    [Intereses],
    [ROWNUMBER]
    from #tempDetallePeriodo
--	select * from #tempListEmp


END
GO
