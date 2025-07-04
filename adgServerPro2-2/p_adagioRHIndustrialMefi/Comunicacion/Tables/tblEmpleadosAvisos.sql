USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comunicacion].[tblEmpleadosAvisos](
	[IDEmpleadoAviso] [int] IDENTITY(1,1) NOT NULL,
	[IDAviso] [int] NULL,
	[IDEmpleado] [int] NULL,
	[TipoFiltro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComunicaciontblEmpleadosAvisos_IDEmpleadoAviso] PRIMARY KEY CLUSTERED 
(
	[IDEmpleadoAviso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comunicacion].[tblEmpleadosAvisos]  WITH CHECK ADD  CONSTRAINT [FK_ComunicaciontblEmpleadosAvisos_ComunicaciontblAvisos_IDAviso] FOREIGN KEY([IDAviso])
REFERENCES [Comunicacion].[tblAvisos] ([IDAviso])
GO
ALTER TABLE [Comunicacion].[tblEmpleadosAvisos] CHECK CONSTRAINT [FK_ComunicaciontblEmpleadosAvisos_ComunicaciontblAvisos_IDAviso]
GO
