USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-22
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROC [Transporte].[spBuscarEstimacionVehiculos] 
(
    @CantidadPersonas int = null    
    
) as

	SET FMTONLY OFF;
	declare  
	   @EstimacionDescripcion  varchar(max);

     
    
    set @EstimacionDescripcion='<p class="card-text"> Se necesitan los siguientes vehículos: </p>
                                <ul style="width:fit-content;margin:auto">';

    declare  @aux  int,@capacidad int;
            set @aux=@CantidadPersonas
            
    
    declare @tempResponse as table (
            [ID] INT IDENTITY (1, 1) NOT NULL,   
            [IDVehiculo] int,
            [Capacidad] int            
    );
    
    while (@aux >0)
    BEGIN
    
        select top 1 @capacidad=CantidadPasajeros  From Transporte.tblCatVehiculos s where s.CantidadPasajeros >=  @aux AND IDVehiculo NOT IN (SELECT IDVehiculo from @tempResponse)
        order by CantidadPasajeros asc        
        
        insert into @tempResponse  (IDVehiculo,Capacidad) 
        select top 1 IDVehiculo,CantidadPasajeros  From Transporte.tblCatVehiculos s where s.CantidadPasajeros >=  @aux AND IDVehiculo NOT IN (SELECT IDVehiculo from @tempResponse)
        order by CantidadPasajeros asc        

        if(@capacidad is null)
        begin 
            select top 1 @capacidad=CantidadPasajeros  From Transporte.tblCatVehiculos s where  IDVehiculo NOT IN (SELECT IDVehiculo from @tempResponse)
            order by CantidadPasajeros desc        
        
            insert into @tempResponse  (IDVehiculo,Capacidad) 
            select top 1 IDVehiculo,CantidadPasajeros  From Transporte.tblCatVehiculos s where   IDVehiculo NOT IN (SELECT IDVehiculo from @tempResponse)
            order by CantidadPasajeros desc        
        end        
        
        set @aux =@aux-@capacidad ;
        set @capacidad=null;
    end

    
    select  @EstimacionDescripcion=@EstimacionDescripcion+concat('<li><span>',count(IDVehiculo),' Vehículo',iif(count(IDVehiculo)=1,'','s'), ' de ',capacidad, ' Personas </span> </li>')
                                    from   @tempResponse 
    GROUP by Capacidad
    set @EstimacionDescripcion=@EstimacionDescripcion+'</ul>';
    SELECT @EstimacionDescripcion [EstimacionDescripcion]
GO
