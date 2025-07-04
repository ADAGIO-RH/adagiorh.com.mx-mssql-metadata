USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Saludoc].[tblProcesosEncuestasCliente](
	[IDProcesoEncuesta] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaInicio] [datetime] NOT NULL,
	[FechaFin] [datetime] NOT NULL,
	[Factor] [decimal](18, 4) NOT NULL,
 CONSTRAINT [PK_SaludocTblProcesosEncuestasCliente_IDProcesoEncuesta] PRIMARY KEY CLUSTERED 
(
	[IDProcesoEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasCliente]  WITH CHECK ADD  CONSTRAINT [FK_RHTBlCatClientes_SaludocTblProcesosEncuestasCliente_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasCliente] CHECK CONSTRAINT [FK_RHTBlCatClientes_SaludocTblProcesosEncuestasCliente_IDCliente]
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasCliente]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_SaludocTblProcesosEncuestasCliente_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Saludoc].[tblProcesosEncuestasCliente] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_SaludocTblProcesosEncuestasCliente_IDUsuario]
GO
