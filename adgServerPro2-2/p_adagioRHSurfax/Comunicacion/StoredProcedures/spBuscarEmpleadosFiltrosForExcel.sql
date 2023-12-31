USE [p_adagioRHSurfax]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-08-29
-- Description:	 
-- SP PARA BUSCAR LOS EMPLEADOS, ESTO PARA VERIFICAR LOS EMPLEADOS DEL EXCEL VS LOS EMPLEADOS DEL COMUNICADO 
-- =============================================
CREATE PROCEDURE [Comunicacion].[spBuscarEmpleadosFiltrosForExcel]
    @dtFiltros [Nomina].[dtFiltrosRH]  READONLY,
    @IDUsuario int ,
    @IsGeneral bit    
AS
BEGIN
    
    if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;    
    if object_id('tempdb..#tempFiltrosAsignarEmpaAvisos') is not null drop table #tempFiltrosAsignarEmpaAvisos;
        
    create table #tempFinalEmpleados (ClaveEmpleado varchar(255))		    

    IF(@IsGeneral = 1 )
        BEGIN
                insert #tempFinalEmpleados
                select m.ClaveEmpleado
                From RH.tblEmpleadosMaster  m                                
                    where  m.Vigente=1
        END
    ELSE
        BEGIN
            	declare         		
                    @empleados [RH].[dtEmpleados]
                    ,@i int = 0
                    ,@fecha date = getdate()
                    ,@Catalogo varchar (255)        
                    ,@dttempFiltros [Nomina].[dtFiltrosRH]                                                                                                
                --select *,
                --        INTO #tempFiltrosAsignarEmpaAvisos
                --from @dtFiltros                                              

                select @i = min(rownumber) from #tempFiltrosAsignarEmpaAvisos
                while exists(select top 1 1 from #tempFiltrosAsignarEmpaAvisos where rownumber >= @i)
                begin
                    delete from @dttempFiltros;
                    delete from @empleados;

                    insert into @dttempFiltros(Catalogo,Value)
                    select  case when Catalogo = 'Excluir Empleados' 
                                then 'Empleados' else Catalogo end , 
                            Value
                    from #tempFiltrosAsignarEmpaAvisos
                        where rownumber = @i

                    select @Catalogo=Catalogo
                        from #tempFiltrosAsignarEmpaAvisos
                    where rownumber = @i

                    insert into @empleados
                    exec [Comunicacion].[spBuscarEmpleados] 
                        @FechaIni	= @fecha
                        ,@Fechafin	= @fecha 
                        ,@IDUsuario	= 1
                        ,@dtFiltros = @dttempFiltros

                    insert #tempFinalEmpleados (ClaveEmpleado)
                    select ClaveEmpleado FROM @empleados

                    select @i = min(rownumber) from #tempFiltrosAsignarEmpaAvisos where rownumber > @i
                end;
                WITH
                TempEmp (ClaveEmpleado, duplicateRecCount)
                AS
                (
                    SELECT ClaveEmpleado, ROW_NUMBER() OVER(PARTITION by ClaveEmpleado ORDER BY ClaveEmpleado) 
                    AS duplicateRecCount
                    FROM #tempFinalEmpleados
                )
                --Now Delete Duplicate Records
                DELETE FROM TempEmp
                WHERE duplicateRecCount > 1
        END                
        select ClaveEmpleado  FROM #tempFinalEmpleados tf    order by ClaveEmpleado
END
GO
