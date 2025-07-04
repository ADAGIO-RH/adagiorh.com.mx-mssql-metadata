USE [p_adagioRHIndustrialMefi]
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

    declare @sumar int 
    

    set @niveles	= isnull((select top 1 [Valor] from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'NivelesSubordinadosPlazas'),3);
    select @IDEmpleado =IDEmpleado, @IDPlaza=IDPlaza from rh.tblCatPosiciones where IDPosicion=@IDPosicion;
    SELECT @IDOrganigrama =IDOrganigrama from rh.tblCatPlazas where IDPlaza=@IDPlaza;




    IF @IDEmpleado IS NOT NULL
    BEGIN               
        set @sumar=0;  
        -- SE OBTIENEN LOS JEFES DE LA POSICION

        

        WITH CTE_Jefes AS -- CTE PARA OBTENER LOS JEFES QUE SE ENCUENTRAN ARRIBA DE LA POSICION
        (  
            SELECT 1 as ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo,IDPosicion as IDPosicionCTE  from rh.tblCatPosiciones where IDEmpleado=@IDEmpleado
                UNION ALL  
            SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo, CTE_Jefes.IDPosicionCTE IDPosicionCTE
                FROM  CTE_Jefes  
                inner join rh.tblCatPosiciones p  WITH(NOLOCK) on p.IDPosicion=CTE_Jefes.[ParentId]                               
        ),
        CTE_Jefes_SinRepetidos as -- CTE PARA QUITAR LOS DUPLICADOS
        (
            SELECT 
                IDEmpleado,
                IDPosicion,
                ParentId,
                Codigo,
                IDPosicionCTE,
                ROW_NUMBER() OVER (PARTITION BY IDEmpleado,IDPosicionCTE ORDER BY ROWNO desc) AS RowMaster,
                ROWNO
            FROM 
            CTE_Jefes
        ),
        CTE_Resutaldo as ( -- CTE DONDE SE SELECCIONAN LOS NIVELES O POSICIONES QUE SON VALIDAS
            SELECT  ROWNO,RowMaster,IDPosicion,ParentId,IDEmpleado,Codigo,0 totalNivelesValidos,0 flagNivelesValidos,CTE_Jefes_SinRepetidos.IDPosicionCTE as IDPosicionCTE from CTE_Jefes_SinRepetidos where IDEmpleado=@IDEmpleado
                UNION ALL  
            SELECT  
            p.ROWNO,p.RowMaster,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo, 
                    case when  
                        p.IDEmpleado is null or 
                        p.IDEmpleado=@IDEmpleado or
                        isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=p.IDEmpleado and IDPosicionCTE= CTE_Resutaldo.IDPosicionCTE  and RowMaster=1),0) < isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=@IDEmpleado and IDPosicionCTE= CTE_Resutaldo.IDPosicionCTE   and  RowMaster=1),-1) or
                        p.RowMaster>1 
                    then totalNivelesValidos else totalNivelesValidos+1 end as totalNivelesValidos ,
                    case when 
                        p.IDEmpleado is null or 
                        p.IDEmpleado=@IDEmpleado or
                        isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=p.IDEmpleado and IDPosicionCTE= CTE_Resutaldo.IDPosicionCTE   and RowMaster=1),0) < isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=@IDEmpleado and IDPosicionCTE= CTE_Resutaldo.IDPosicionCTE   and  RowMaster=1),-1) or
                        p.RowMaster>1 
                    then 0 else 1 end as flagNivelesValidos,
                    CTE_Resutaldo.IDPosicionCTE as IDPosicionCTE
                FROM  CTE_Resutaldo                   
                inner join CTE_Jefes_SinRepetidos p on p.IDPosicion=CTE_Resutaldo.[ParentId] 
            where totalNivelesValidos < @niveles 
        )                                    
        insert into @dtJefesEmpleados (IDEmpleado,IDJefe,Nivel,FechaReg,IDOrganigrama)
        SELECt @IDEmpleado,IDEmpleado as [Jefe],totalNivelesValidos as nivel,GETDATE(),@IDOrganigrama  FROM CTE_Resutaldo where flagNivelesValidos=1 and ROWNO!=1;        
        
        delete from [RH].[tblJefesEmpleados] where IDJefe  not in (select IDJefe From @dtJefesEmpleados ) and IDEmpleado=@IDEmpleado and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null)
        and IDOrganigrama=@IDOrganigrama;

        update e 
        set e.Nivel=p.Nivel,
            e.FechaReg=p.FechaReg,
            e.IDOrganigrama=p.IDOrganigrama
        from rh.tblJefesEmpleados  e
        inner join @dtJefesEmpleados p on p.IDEmpleado=e.IDEmpleado and p.IDJefe=e.IDJefe;

        delete from @dtJefesEmpleados where IDJefe in (select IDJefe from RH.tblJefesEmpleados where IDEmpleado=@IDEmpleado) and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null);
        insert into rh.tblJefesEmpleados (IDEmpleado,IDJefe,FechaReg,Nivel,IDOrganigrama)
        select IDEmpleado, IDJefe,FechaReg,Nivel,IDOrganigrama from @dtJefesEmpleados;
        
        
    END ELSE
    BEGIN
        set @sumar=1;  
    END;
                  
    --SE OBTIENEN LOS SUBORDINADOS DE LA POSICION
    WITH CTE_Jefes AS
    (  
        SELECT 1 as ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo,IDPosicion AS IDPosicionCTE from rh.tblCatPosiciones with (nolock) where IDEmpleado=@IDEmpleado
            UNION ALL  
        SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo, CTE_Jefes.IDPosicionCTE AS IDPosicionCTE
            FROM  CTE_Jefes  
            inner join rh.tblCatPosiciones p  WITH(NOLOCK) on p.IDPosicion=CTE_Jefes.[ParentId]                   
    ),
    CTE_Jefes_SinRepetidos AS
    (  
        SELECT 
            IDEmpleado,
            IDPosicion,
            ParentId,
            Codigo,
            ROW_NUMBER() OVER (PARTITION BY IDEmpleado,IDPosicionCTE ORDER BY ROWNO) AS RowMaster,
            IDPosicionCTE,
            ROWNO
        FROM 
        CTE_Jefes
    ),
    CTE_Subordinados AS
    (  
        SELECT 1 as ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo,IDPosicion AS IDPosicionCTE  from rh.tblCatPosiciones with (nolock) where IDEmpleado=@IDEmpleado
            UNION ALL  
        SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo,CTE_Subordinados.IDPosicionCTE AS IDPosicionCTE 
            FROM  CTE_Subordinados  
        inner join rh.tblCatPosiciones p  WITH(NOLOCK) on p.ParentId=CTE_Subordinados.[IDPosicion]                                      
    ),
    CTE_Subordinados_SinRepetidos AS
    (  
        SELECT 
            IDEmpleado,
            IDPosicion,
            ParentId,
            Codigo,
            IDPosicionCTE,
            ROW_NUMBER() OVER (PARTITION BY IDEmpleado,IDPosicionCTE ORDER BY ROWNO) AS RowMaster,
            ROWNO
        FROM 
        CTE_Subordinados
    )
    ,CTE_Resultado as (
        SELECT ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo, 0 totalNivelesValidos,0 flagNivelesValidos,CTE_Subordinados_SinRepetidos.IDPosicionCTE AS IDPosicionCTE from CTE_Subordinados_SinRepetidos where IDEmpleado=@IDEmpleado and RowMaster=1
            UNION ALL  
        SELECT  p.ROWNO,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo,
                case when 
                    p.IDEmpleado is null or 
                    p.IDEmpleado=@IDEmpleado or
                    isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=p.IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),0) <= isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=@IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),-1) or
                    isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=p.IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),-1) > isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=@IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),0)  or
                    p.RowMaster>1                     
                then totalNivelesValidos else totalNivelesValidos+1 end as totalNivelesValidos ,
                 case when 
                    p.IDEmpleado is null or 
                    p.IDEmpleado=@IDEmpleado or
                    isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=p.IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),0) <= isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=@IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),-1) or 
                    isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=p.IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),-1) > isnull((select ROWNO from CTE_Jefes_SinRepetidos where IDEmpleado=@IDEmpleado and IDPosicionCTE=p.IDPosicionCTE and RowMaster=1),0)  or
                    p.RowMaster>1 
                then 0 else 1 end as flagNivelesValidos                 ,
                p.IDPosicionCTE                              
            FROM  CTE_Subordinados_SinRepetidos p
            inner join CTE_Resultado on p.ParentId=CTE_Resultado.IDPosicion              
        where totalNivelesValidos < @niveles+@sumar
    )              
    insert into @dtSubordinados (RowNo,IDPosicion,IDEmpleado,IDJefe,Nivel,FechaReg,IDOrganigrama)
    SELECt ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),IDPosicion,IDEmpleado,@IDEmpleado as [Jefe],totalNivelesValidos as nivel,GETDATE(),@IDOrganigrama  FROM CTE_Resultado where flagNivelesValidos=1 and ROWNO!=1 ;    
         
    delete from rh.tblJefesEmpleados where IDJefe=@IDEmpleado
    and IDEmpleado  not in (select IDEmpleado from @dtSubordinados)
    and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null);    
    
    
    declare  @total  int
    declare @row int
    select  @total=count(*) from @dtSubordinados
    set @row=1;

    while (@row <=@total)
    BEGIN
        delete from @dtJefesEmpleadosSubordinados;
        declare @IDEmpleadoSubordinado int , @IDPosicionSubordinado int;        

        select @IDEmpleadoSubordinado=IDEmpleado,@IDPosicionSubordinado=IDPosicion  From @dtSubordinados where RowNo=@row;

        WITH CTE_Subordinados AS -- CTE PARA OBTENER LOS JEFES QUE SE ENCUENTRAN ARRIBA DE LA POSICION
        (  
            SELECT 1 as ROWNO,IDPosicion,ParentId,IDEmpleado,Codigo,IDPosicion as IDPosicionCTE from rh.tblCatPosiciones  with (nolock)  where IDPosicion=@IDPosicionSubordinado
                UNION ALL  
            SELECT  ROWNO+1,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo ,CTE_Subordinados.IDPosicionCTE               
                FROM  CTE_Subordinados  
                inner join rh.tblCatPosiciones p with (nolock)   on p.IDPosicion=CTE_Subordinados.[ParentId]                               
        ),
        CTE_Subordinados_SinRepetidos as -- CTE PARA QUITAR LOS DUPLICADOS
        (
            SELECT 
                IDEmpleado,
                IDPosicion,
                ParentId,
                Codigo,
                IDPosicionCTE,
                ROW_NUMBER() OVER (PARTITION BY IDEmpleado,IDPosicionCTE ORDER BY ROWNO desc) AS RowMaster,
                ROWNO
            FROM 
            CTE_Subordinados
        ) ,
        CTE_Resutaldo as ( -- CTE DONDE SE SELECCIONAN LOS NIVELES O POSICIONES QUE SON VALIDAS
            SELECT  ROWNO,RowMaster,IDPosicion,ParentId,IDEmpleado,Codigo,0 totalNivelesValidos,0 flagNivelesValidos,CTE_Subordinados_SinRepetidos.IDPosicionCTE from CTE_Subordinados_SinRepetidos where IDPosicion=@IDPosicionSubordinado
                UNION ALL  
            SELECT  p.ROWNO,p.RowMaster,p.IDPosicion,p.ParentId,p.IDEmpleado,p.Codigo, 
                    case when  
                        p.IDEmpleado is null or 
                        p.IDEmpleado=@IDEmpleadoSubordinado or
                        isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=p.IDEmpleado And  IDPosicionCTE=CTE_Resutaldo.IDPosicionCTE  and RowMaster=1),0) <= isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=@IDEmpleadoSubordinado And  IDPosicionCTE=CTE_Resutaldo.IDPosicionCTE and  RowMaster=1),-1) or
                        p.RowMaster>1 
                    then totalNivelesValidos else totalNivelesValidos+1 end as totalNivelesValidos ,
                    case when 
                        p.IDEmpleado is null or 
                        p.IDEmpleado=@IDEmpleadoSubordinado or
                        isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=p.IDEmpleado And  IDPosicionCTE=CTE_Resutaldo.IDPosicionCTE and RowMaster=1),0) <= isnull((select ROWNO from CTE_Subordinados_SinRepetidos where IDEmpleado=@IDEmpleadoSubordinado And  IDPosicionCTE=CTE_Resutaldo.IDPosicionCTE and  RowMaster=1),-1) or
                        p.RowMaster>1 
                    then 0 else 1 end as flagNivelesValidos                                              ,
                    CTE_Resutaldo.IDPosicionCTE
                FROM  CTE_Resutaldo                   
                inner join CTE_Subordinados_SinRepetidos p on p.IDPosicion=CTE_Resutaldo.[ParentId] 
            where totalNivelesValidos < @niveles 
        )        
        insert into @dtJefesEmpleadosSubordinados (IDEmpleado,IDJefe,Nivel,FechaReg,IDOrganigrama)
        SELECt @IDEmpleadoSubordinado,IDEmpleado as [Jefe],totalNivelesValidos as nivel,GETDATE(),@IDOrganigrama  FROM CTE_Resutaldo where flagNivelesValidos=1  and ROWNO!=1;
                
         delete from [RH].[tblJefesEmpleados] where IDJefe  in (select IDJefe From @dtJefesEmpleadosSubordinados ) and IDEmpleado=@IDEmpleadoSubordinado and (Nivel is not null and IDOrganigrama is not null and FechaReg is not null) 
         and IDOrganigrama=@IDOrganigrama;

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
