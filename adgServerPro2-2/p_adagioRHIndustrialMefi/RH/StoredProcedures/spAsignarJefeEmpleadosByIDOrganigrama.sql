USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- =============================================
 -- Author:		Jose Vargas
 -- Create date: 2022-01-27
 -- Description: SP PARA ACTUALIZAR LOS JEFES EN BASE AL ORGANIGRAMA. (TODO EL ORGANIGRAMA)
 -- =============================================
 CREATE PROCEDURE [RH].[spAsignarJefeEmpleadosByIDOrganigrama]    
    @IDOrganigrama int =null
    -- @Filtro varchar(255) = null,
    -- @IDReferencia int  = null     
 AS
 BEGIN             
    declare @empleadosPosiciones as table (        
        IDPosicion int,        
        RowNumber int 
    );

    WITH CTE_POSICIONES AS
    (    
        SELECT  0 RowNo , IDPosicion, po.ParentID, IDEmpleado, 0 AS Nivel
        FROM  rh.tblCatPosiciones   po with (nolock )
        inner join rh.tblCatPlazas pl with (nolock ) on pl.IDPlaza=po.IDPlaza
        WHERE  po.ParentID =0  and pl.IDOrganigrama=@IDOrganigrama
            UNION ALL    
        SELECT  RowNo +1 as  RowNo , o.IDPosicion, o.ParentID, o.IDEmpleado, Nivel + 1        
        FROM  rh.tblCatPosiciones   o with (nolock)
        INNER JOIN  CTE_POSICIONES cte ON o.ParentID = cte.IDPosicion 
    ),
    CTE_POSICIONES_SINREPETIR as (
        select IDPosicion,IDEmpleado ,RowNo,ROW_NUMBER() OVER (PARTITION BY IDEmpleado ORDER BY ROWNO asc) AS RowNum from CTE_POSICIONES 
    )       
    insert into @empleadosPosiciones (RowNumber,IDPosicion)
    select ROW_NUMBER() OVER ( ORDER BY ROWNO asc),IDPosicion from CTE_POSICIONES_SINREPETIR   where RowNum =1  and IDEmpleado is not null order by RowNo


    -- INSERT  into @empleadosPosiciones  (IDPosicion,RowNumber)
    -- SELECT IDPosicion,ROW_NUMBER() OVER(ORDER BY (SELECT NULL))  fROM RH.tblCatPosiciones po
    -- INNER JOIN RH.tblCatPlazas pl ON  pl.IDPlaza=po.IDPlaza
    -- WHERE IDOrganigrama=@IDOrganigrama
    -- select * From @empleadosPosiciones

    declare  @total  int
    declare @row int
    select  @total=count(*) from @empleadosPosiciones
    set @row=1          

    WHILE (@row <=@total)
    BEGIN
        
        DECLARE @IDPosicionTemp int;
        select @IDPosicionTemp=IDPosicion From @empleadosPosiciones where RowNumber =@ROW;
        
        EXEC [RH].[spAsignarJefesEmpleadosOrganigramaIndividual] @IDPosicion=@IDPosicionTemp 
        set @row=@row+1;
    end

 END
GO
