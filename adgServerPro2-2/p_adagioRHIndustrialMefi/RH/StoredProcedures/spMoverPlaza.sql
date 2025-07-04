USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [RH].[spMoverPlaza](
	@IDPlaza int,
    @IDPlazaTarget int,
	@IDPosicionTarget int,
	@IDUsuario int
) as
	
    declare @jsonr varchar(max)
    select @jsonr=Configuraciones From rh.tblCatPlazas where IDPlaza=@IDPlaza
    declare @configuracion VARCHAR(max)   
 
    declare @tabla   as table (
        IDTipoConfiguracionPlaza varchar(200),
        Valor int,
        Descripcion varchar(200)
    )
    insert into @tabla
    SELECT *
        FROM OPENJSON ( @jsonr )  
        WITH (                               
              IDTipoConfiguracionPlaza VARCHAR(200)   '$.IDTipoConfiguracionPlaza',  
              Valor INT            '$.Valor'              ,
              Descripcion VARCHAR(200)   '$.Descripcion'
            )
 
 
    set @configuracion=(select 
        IDTipoConfiguracionPlaza,
        case when 
            IDTipoConfiguracionPlaza='PosicionJefe' then @IDPosicionTarget else Valor end as [Valor],           
        Descripcion
    From @tabla
    for JSON auto)

    
    update RH.tblCatPlazas set ParentId=@IDPlazaTarget  , Configuraciones=@configuracion
    where IDPlaza=@IDPlaza;


    update rh.tblCatPosiciones set ParentId =@IDPosicionTarget 
    where IDPlaza=@IDPlaza;
    

    declare @dtPosiciones as table(
        rowNo int,
        IDPosicion int 
    );

    INSERT INTO @dtPosiciones (rowNo,IDPosicion)
    SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)),IDPosicion from rh.tblCatPosiciones where IDPlaza = @IDPlaza and IDEmpleado is not null
    declare  @total  int
    declare @row int
    select  @total=count(*) from @dtPosiciones
    set @row=1          

    WHILE (@row <=@total)
    BEGIN

        DECLARE @IDPosicionTemp int;
        select @IDPosicionTemp=IDPosicion From @dtPosiciones where rowNO =@ROW        
        EXEC [RH].[spAsignarJefesEmpleadosOrganigramaIndividual] @IDPosicion=@IDPosicionTemp
        set @row=@row+1;
    end
GO
