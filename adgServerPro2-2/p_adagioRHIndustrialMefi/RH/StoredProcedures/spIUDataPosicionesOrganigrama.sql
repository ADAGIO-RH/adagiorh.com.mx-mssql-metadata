USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualizar JSON de la tabla  rh.tblOrganigramasPosiciones
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-03-30
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
-- Drop the stored procedure called 'StoredProcedureName' in schema 'dbo'
CREATE proc [RH].[spIUDataPosicionesOrganigrama] (
	@IDOrganigramaPosicion int , 
    @IDPosicion int ,
	@IDEmpleado int ,
    @IDPuesto int , 
    @Codigo varchar(10),
    @pid int  ,
    @IDEstatus int ,
    @EsAsistente bit     ,
    @IDNivelEmpresarial int,
    @IDUsuario int 
    
) as
	SET  FMTONLY OFF;  
    DECLARE @dtOrganitrama as table(    
        IDPosicion int ,
        IDEmpleado int ,
        IDEstatus int ,
        pid int  ,
        EsAsistente bit,
        IDPuesto int , 
        Codigo varchar(10),
        Temporal bit,
        IDNivelEmpresarial int 
    );
    declare @json varchar(max)
    IF  @IDPosicion <> 0
    BEGIN        
        select @json=[Data] from rh.tblOrganigramasPosiciones     where IDOrganigramaPosicion=@IDOrganigramaPosicion      
        insert into @dtOrganitrama 
        select * FROM  OPENJSON(@json) with (
                    IDPosicion int ,
	                IDEmpleado int ,
                    IDEstatus int ,                    
                    pid int  ,
                    EsAsistente bit,
                    IDPuesto int , 
                    Codigo varchar(10),
                    Temporal BIT ,
                    IDNivelEmpresarial int
        );         

        update @dtOrganitrama set IDEmpleado = @IDEmpleado ,
                IDEstatus=@IDEstatus,
                pid= @pid,
                EsAsistente = @EsAsistente                
        where IDPosicion=@IDPosicion

        update rh.tblOrganigramasPosiciones set Data = ( select * from ( select * from @dtOrganitrama) info for json auto ) 
        where IDOrganigramaPosicion = @IDOrganigramaPosicion        
                
        exec [RH].[spBuscarOneOrganigramasPosiciones]  @IDOrganigramaPosicion=@IDOrganigramaPosicion , @IDUsuario=@IDUsuario, @CodigoPlaza=@Codigo        
    END ELSE 
    BEGIN 
    
        select @json=[Data] from rh.tblOrganigramasPosiciones     where IDOrganigramaPosicion=@IDOrganigramaPosicion   

        insert into @dtOrganitrama
        select * FROM  OPENJSON(@json) with (
                    IDPosicion int ,
	                IDEmpleado int ,
                    IDEstatus int ,                    
                    pid int  ,
                    EsAsistente bit,
                    IDPuesto int , 
                    Codigo varchar(10),
                    Temporal BIT ,
                    IDNivelEmpresarial int 
        );      

        DECLARE @min INT = 100000;
        DECLARE @max INT = 999999;
        DECLARE @range INT = @max - @min + 1;
                
        if( exists(select top 1 1 from @dtOrganitrama where Codigo=@Codigo))
        BEGIN
            raiserror('El código ingresado ya se encuentra en uso.',16,1);                
        end else
        begin        
            insert into  @dtOrganitrama (
                IDPosicion  ,
                IDEmpleado  ,
                IDEstatus  ,
                pid   ,
                EsAsistente ,
                IDPuesto , 
                Codigo ,Temporal ,IDNivelEmpresarial) values (CAST((RAND() * @range) + @min AS INT),0,2,@pid,@EsAsistente,@IDPuesto,@Codigo,1,@IDNivelEmpresarial)
                

            update rh.tblOrganigramasPosiciones set Data = ( select * from ( select * from @dtOrganitrama) info for json auto ) 
            where IDOrganigramaPosicion = @IDOrganigramaPosicion        

            exec [RH].[spBuscarOneOrganigramasPosiciones]  @IDOrganigramaPosicion=@IDOrganigramaPosicion , @IDUsuario=@IDUsuario, @CodigoPlaza=@Codigo
        end
    END
GO
