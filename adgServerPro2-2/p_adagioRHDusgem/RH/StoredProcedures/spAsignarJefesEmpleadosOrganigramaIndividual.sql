USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
--  -- =============================================
--  -- Author:		Jose Vargas
--  -- Create date: 2022-01-27
--  -- Description: SP PARA ASIGNAR JEFES EN BASE AL ORGANIGRAMA DE MANERA INDIVIDUAL
--  -- =============================================
 CREATE PROCEDURE [RH].[spAsignarJefesEmpleadosOrganigramaIndividual]
     @IDPosicion int =null
    
 AS
 BEGIN             
    
    DECLARE @IDEmpleado int;
    DECLARE @niveles int ;  
    declare @IDPlaza int;
    DECLARE @IDOrganigrama int;
              
    declare @dtJefesEmpleadosSubordinados as table(
        IDEmpleado int , 
        IDJefe int ,
        Nivel int,
        IDOrganigrama int ,
        FechaReg datetime 
    );

    declare @dtJefesEmpleados as table(
        IDEmpleado int , 
        IDJefe int ,
        Nivel int,
        IDOrganigrama int ,
        FechaReg datetime 
    );
    declare @dtSubordinados as table(
        RowNo int ,
        IDPosicion int,
        IDEmpleado int , 
        IDJefe int ,
        Nivel int,
        IDOrganigrama int ,
        FechaReg datetime 
    );

    set @niveles	= isnull((select top 1 [Valor] from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'NivelesSubordinadosPlazas'),3);
    select @IDEmpleado =IDEmpleado, @IDPlaza=IDPlaza from rh.tblCatPosiciones where IDPosicion=@IDPosicion;
    SELECT @IDOrganigrama =IDOrganigrama from rh.tblCatPlazas where IDPlaza=@IDPlaza;


    
    
    
    
    
    -- SE OBTIENEN LOS JEFES DEL EMPLEADO
    WITH ROWCTE AS
    (  
        SELECT 1 as ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo,0 totalNivelesValidos from rh.tblCatPosiciones where IDPosicion=@IDPosicion
            UNION ALL  
        SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo, case when p.IDEmpleado is null then totalNivelesValidos else totalNivelesValidos+1 end as totalNivelesValidos
            FROM  ROWCTE  
            inner join rh.tblCatPosiciones p on p.IDPosicion=ROWCTE.[ParentId]  
            WHERE totalNivelesValidos <@niveles
    )        
    insert into @dtJefesEmpleados (IDEmpleado,IDJefe,Nivel,FechaReg,IDOrganigrama)
    SELECt @IDEmpleado,IDEmpleado as [Jefe],totalNivelesValidos as nivel,GETDATE(),@IDOrganigrama  FROM ROWCTE where IDEmpleado is not null and ROWNO!=1;

    

    delete from [RH].[tblJefesEmpleados] where IDJefe not in (select IDJefe From @dtJefesEmpleados ) and IDEmpleado=@IDEmpleado and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null);
    update e 
    set e.Nivel=p.Nivel,
        e.FechaReg=p.FechaReg,
        e.IDOrganigrama=p.IDOrganigrama
    from rh.tblJefesEmpleados  e
    inner join @dtJefesEmpleados p on p.IDEmpleado=e.IDEmpleado and p.IDJefe=e.IDJefe;

    delete from @dtJefesEmpleados where IDJefe in (select IDJefe from RH.tblJefesEmpleados where IDEmpleado=@IDEmpleado) and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null);;
    insert into rh.tblJefesEmpleados (IDEmpleado,IDJefe,FechaReg,Nivel,IDOrganigrama)
    select IDEmpleado, IDJefe,FechaReg,Nivel,IDOrganigrama from @dtJefesEmpleados;

         
    --SE OBTIENEN LOS SUBORDINADOS
    WITH ROWCTE AS
    (  
        SELECT 1 as ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo,0 totalNivelesValidos from rh.tblCatPosiciones where IDPosicion=@IDPosicion
            UNION ALL  
        SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo, case when p.IDEmpleado is null then totalNivelesValidos else totalNivelesValidos+1 end as totalNivelesValidos
            FROM  ROWCTE  
            inner join rh.tblCatPosiciones p on p.ParentId=ROWCTE.[IDPosicion]  
            WHERE totalNivelesValidos <@niveles
    )    
    insert into @dtSubordinados (RowNo,IDPosicion,IDEmpleado,IDJefe,Nivel,FechaReg,IDOrganigrama)
    SELECt ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),IDPosicion,IDEmpleado,@IDEmpleado as [Jefe],totalNivelesValidos as nivel,GETDATE(),@IDOrganigrama  FROM ROWCTE where IDEmpleado is not null and ROWNO!=1;


    declare  @total  int
    declare @row int
    select  @total=count(*) from @dtSubordinados
    set @row=1;

    while (@row <=@total)
    BEGIN
        delete from @dtJefesEmpleadosSubordinados;
        declare @IDEmpleadoSubordinado int , @IDPosicionSubordinado int;        

        select @IDEmpleadoSubordinado=IDEmpleado,@IDPosicionSubordinado=IDPosicion  From @dtSubordinados where RowNo=@row;
         WITH ROWCTE AS
        (  
            SELECT 1 as ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo,0 totalNivelesValidos from rh.tblCatPosiciones where IDPosicion=@IDPosicionSubordinado
                UNION ALL  
            SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo, case when p.IDEmpleado is null then totalNivelesValidos else totalNivelesValidos+1 end as totalNivelesValidos
                FROM  ROWCTE  
                inner join rh.tblCatPosiciones p on p.IDPosicion=ROWCTE.[ParentId]  
                WHERE totalNivelesValidos <@niveles
        )        
        insert into @dtJefesEmpleadosSubordinados (IDEmpleado,IDJefe,Nivel,FechaReg,IDOrganigrama)
        SELECt @IDEmpleadoSubordinado,IDEmpleado as [Jefe],totalNivelesValidos as nivel,GETDATE(),@IDOrganigrama  FROM ROWCTE where IDEmpleado is not null and ROWNO!=1;

        
        delete from [RH].[tblJefesEmpleados] where IDJefe not in (select IDJefe From @dtJefesEmpleadosSubordinados ) and IDEmpleado=@IDEmpleadoSubordinado and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null);;

        update e 
        set e.Nivel=p.Nivel,
            e.FechaReg=p.FechaReg,
            e.IDOrganigrama=p.IDOrganigrama
        from rh.tblJefesEmpleados  e
        inner join @dtJefesEmpleadosSubordinados p on p.IDEmpleado=e.IDEmpleado and p.IDJefe=e.IDJefe;

        delete from @dtJefesEmpleadosSubordinados where IDJefe in (select IDJefe from RH.tblJefesEmpleados where IDEmpleado=@IDEmpleadoSubordinado) and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null);;

        insert into rh.tblJefesEmpleados (IDEmpleado,IDJefe,FechaReg,Nivel,IDOrganigrama)
        select IDEmpleado, IDJefe,FechaReg,Nivel,IDOrganigrama from @dtJefesEmpleadosSubordinados;
        
        set @row=@row+1;
    end

     
  END
GO
