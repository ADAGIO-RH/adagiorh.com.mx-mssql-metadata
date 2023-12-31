USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [Bk].[fnValidarMovCorrectos](@IDEmpleado int)
returns bit
as
BEGIN

    declare 
        @DIVMOV INT
        ,@IDTipoMovimiento INT
        ,@FechaBaja date
        -- ,@IDEmpleado int = 1
    ;

    DECLARE @temp as table(
        DIVMOV int,
        IDTipoMovimiento int,
        Fecha date
    )

    insert @temp
    SELECT    
        ROW_NUMBER() OVER(PARTITION BY IDEmpleado ORDER BY Fecha DESC, IDMovAfiliatorio) AS DIVMOV
        ,IDTipoMovimiento
        ,Fecha
    FROM IMSS.tblMovAfiliatorios WITH (nolock) 
    where IDEmpleado = @IDEmpleado

    -- select *
    -- from @temp


    select top 1 
        @IDTipoMovimiento = IDTipoMovimiento,
        @DIVMOV = DIVMOV,
        @FechaBaja = Fecha
    from @temp
    where IDTipoMovimiento = 2
    order by DIVMOV asc

    -- select
    --    @IDTipoMovimiento as IDTipoMovimiento,
    --     @DIVMOV as DIVMOV

    if exists (select top 1 1 from @temp where DIVMOV = (@DIVMOV - 1) and IDTipoMovimiento <> 3 and Fecha <> @FechaBaja)
    BEGIN
   
        return 1
    END

    return 0
END

--select * from IMSS.tblCatTipoMovimientos
GO
