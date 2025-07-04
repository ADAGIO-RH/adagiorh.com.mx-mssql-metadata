USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar empleados para generar el template de excel, para la asignación en la creación de comunicados/avisos.
** Autor			: JOSE VARGAS
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-08-29
** Paremetros		:              
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2023-10-03          Jose Vargas         Se reemplaza el sp `[Comunicacion].[spBuscarEmpleados]` por `[RH].[spBuscarEmpleadosMaster]` por motivo de lentitud.
2023-10-03          Jose Vargas         Se agrega validación para evitar buscar los empleados con el filtro `Excluir Empleado` (este se obtiene de `[Seguridad].[spBuscarTiposFiltros]`)
										en el template de excel.
***************************************************************************************************/
CREATE PROCEDURE [Comunicacion].[spBuscarEmpleadosFiltrosForExcel]
    @dtFiltros [Nomina].[dtFiltrosRH]  READONLY,
    @IDUsuario int ,
    @IsGeneral bit    
AS
BEGIN
    
    if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;    
    if object_id('tempdb..#tempFiltrosAsignarEmpaAvisos') is not null drop table #tempFiltrosAsignarEmpaAvisos;
        
    create table #tempFinalEmpleados ( 
        IDEmpleado int,
        ClaveEmpleado varchar(255)
    )		    
    IF(@IsGeneral = 1 )
        BEGIN
            INSERT #tempFinalEmpleados
            SELECT m.ClaveEmpleado FROM RH.tblEmpleadosMaster  m WHERE  m.Vigente=1
        END
    ELSE
        BEGIN
            DECLARE         		
                @empleados [RH].[dtEmpleados]
                ,@i int = 0
                ,@fecha date = getdate()                
                ,@dttempFiltros [Nomina].[dtFiltrosRH]                                                                                                
                				          
			select *,ROW_NUMBER()OVER( ORDER BY (SELECT NULL)) AS rownumber 
            INTO #tempFiltrosAsignarEmpaAvisos
            from @dtFiltros  WHERE Catalogo <> 'Excluir Empleado'			                                     

            SELECT @i = min(rownumber) from #tempFiltrosAsignarEmpaAvisos
            while exists(select top 1 1 from #tempFiltrosAsignarEmpaAvisos where rownumber >= @i)
            begin
                delete from @dttempFiltros;
                delete from @empleados;

                insert into @dttempFiltros(Catalogo,Value)
                select  Catalogo , Value from #tempFiltrosAsignarEmpaAvisos where rownumber = @i                
                
                insert into @empleados
                --exec [COMUNICACION].[spBuscarEmpleados] 
                -- Subordinados, Usuarios, IDTipoNonima
                exec [RH].[spBuscarEmpleadosMaster] 
                    @FechaIni	= @fecha
                    ,@Fechafin	= @fecha 
                    ,@IDUsuario	= 1
                    ,@dtFiltros = @dttempFiltros

                insert #tempFinalEmpleados (IDEmpleado,ClaveEmpleado)
                select IDEmpleado,ClaveEmpleado FROM @empleados

                select @i = min(rownumber) from #tempFiltrosAsignarEmpaAvisos where rownumber > @i
            end;

            delete #tempFinalEmpleados where  IDEmpleado in (
                            Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo in('Excluir Empleado','Excluir Usuarios')),',')
            );    
            
            
            WITH TempEmp (ClaveEmpleado, duplicateRecCount)
            AS
            (
                SELECT ClaveEmpleado, ROW_NUMBER() OVER(PARTITION by ClaveEmpleado ORDER BY ClaveEmpleado)  AS duplicateRecCount FROM #tempFinalEmpleados
            )
            --Now Delete Duplicate Records
            DELETE FROM TempEmp
            WHERE duplicateRecCount > 1
        END                
        select ClaveEmpleado  FROM #tempFinalEmpleados tf    order by ClaveEmpleado
END
GO
