USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- =============================================
 -- Author:		Jose Vargas
 -- Create date: 2022-01-27
 -- Description: SP PARA ASIGNAR JEFES EN BASE AL ORGANIGRAMA
 -- =============================================
 CREATE PROCEDURE [RH].[spAsignarJefeEmpleadosByPosicion]
    @IDEmpleado int =null,
    @Filtro varchar(255) = null,
    @IDReferencia int  = null
     -- Add the parameters for the stored procedure here	
 AS
 BEGIN             
    declare @empleadosPosiciones as table (
        IDEmpleado int ,
        IDPosicion int,
        IDParentPosicion int,
        RowNumber int 
    )
    declare @IDOrganigrama int

    select @IDOrganigrama =IDOrganigrama from rh.tblCatOrganigramas s where s.Filtro=@Filtro AND S.IDReferencia   =@IDReferencia;

    insert into @empleadosPosiciones  (IDEmpleado,IDPosicion,IDParentPosicion,RowNumber)
    select IDEmpleado,IDPosicion,ParentId,ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) From rh.tblCatPosiciones  p
    where p.IDEmpleado is not null  and (@IDEmpleado is null or p.IDEmpleado=@IDEmpleado)  

    declare @niveles int     
    set @niveles	= isnull((select top 1 [Valor] from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'NivelesSubordinadosPlazas'),3)

    DELETE  d
        from rh.tblJefesEmpleados d
    inner join rh.tblCatPosiciones pp on pp.IDEmpleado in (d.IDEmpleado,d.IDJefe)    
    where pp.IDEmpleado = @IDEmpleado or @IDEmpleado is null


    declare  @total  int
    declare @row int
    select  @total=count(*) from @empleadosPosiciones
    set @row=1          

    while (@row <=@total)
    BEGIN

        DECLARE @IDEmpleadoTemp int ,@IDPosicionTemp int; 
        select 
            @IDEmpleadoTemp=IDEmpleado,
            @IDPosicionTemp =IDPosicion        
        from @empleadosPosiciones where RowNumber= @row    

        declare @dtEmpleado as table(
            IDEmpleado int , 
            IDJefe int ,
            Nivel int
        )

        

        Declare @RowNo int =1;
        WITH ROWCTE AS
        (  
            SELECT @RowNo as ROWNO,IDPosicion,ParentId,IDEmpleado from rh.tblCatPosiciones where IDPosicion=@IDPosicionTemp
                UNION ALL  
            SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado
                FROM  ROWCTE  
                inner join rh.tblCatPosiciones p on p.ParentId=ROWCTE.IDPosicion
            WHERE RowNo <= @niveles
        )    
        insert into @dtEmpleado (IDEmpleado,IDJefe,Nivel)
        SELECt IDEmpleado,@IDEmpleadoTemp as [Jefe],ROWNO-1 as nivel  FROM ROWCTE where IDEmpleado is not null and ROWNO!=1

        delete from rh.tblJefesEmpleados where IDEmpleado in (select IDEmpleado  from @dtEmpleado) and Nivel is not null

        insert into rh.tblJefesEmpleados (IDEmpleado,IDJefe,Nivel,IDOrganigrama)
        select IDEmpleado,IDJefe,Nivel,@IDOrganigrama  From @dtEmpleado

        set @row=@row+1;
    end
 END
GO
